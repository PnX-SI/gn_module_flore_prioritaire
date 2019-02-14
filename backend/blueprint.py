from flask import Blueprint,request

from shapely.geometry import asShape
from geoalchemy2.shape import from_shape
from geojson import FeatureCollection

from geonature.utils.env import DB
from geonature.utils.utilssqlalchemy import (
    json_resp,
    GenericTable
)
from pypnusershub.db.models import User
from .models import TZprospect, TApresence, corApArea, corZpArea, corApPerturb, corZpObs
from geonature.core.taxonomie.models import Taxref
from geonature.core.gn_monitoring.models import corVisitObserver, corSiteModule, TBaseVisits
from geonature.core.ref_geo.models import LAreas
from geonature.core.users.models import BibOrganismes

blueprint = Blueprint('pr_priority_flora', __name__)

@blueprint.route('/z_prospects', methods=['GET'])
@json_resp
def get_zprospect():
    '''
    Retourne toutes les zones de prospection du module
    '''
    parameters = request.args
    q = (
        DB.session.query(
        TZprospect,
        Taxref
        ).outerjoin(
            Taxref, TZprospect.cd_nom == Taxref.cd_nom
        )
    )
    if 'indexzp' in parameters:
        q = q.filter(TZprospect.indexzp == parameters['indexzp'])

    if 'cd_nom' in parameters:
        q = q.filter(Taxref.cd_nom == parameters['cd_nom'])

    data = q.all()
    features = []

    for d in data:
        feature = d[0].as_geofeature('geom_4326','indexzp',True)
        id_zp = feature['properties']['indexzp']
        feature['properties']['taxon'] = d[1].as_dict()
        features.append(feature)
        
    return FeatureCollection(features)

@blueprint.route('/apresences', methods=['GET'])
@json_resp
def get_apresences():
    '''
    Retourne toutes les aires de présence d'une zone de prospection
    '''
    parameters = request.args
    q = DB.session.query(TApresence)
    if 'indexzp' in parameters:
        q = q.filter(TApresence.indexzp == parameters['indexzp'])
    data = q.all()
    return [d.as_dict(True) for d in data]

@blueprint.route('/form', methods=['POST'])
@json_resp
def post_visit():
    '''
    Poste une nouvelle zone de prospection
    '''
    data = dict(request.get_json())
    shape = asShape(data['geom_4326'])
    releve= TZprospect(**data)
    releve.geom_4326 = from_shape(shape, srid=4326)
    DB.session.add(releve)
    DB.session.commit()
    DB.session.flush()
    return releve.as_geofeature('geom_4326','indexzp',True)
    

@blueprint.route('/organismes', methods=['GET'])
@json_resp
def get_organisme():
    '''
    Retourne la liste de tous les organismes présents
    '''

    q = DB.session.query(
        BibOrganismes.nom_organisme).distinct().join(
        User, BibOrganismes.id_organisme == User.id_organisme).join(
        corZpObs, User.id_role == corZpObs.c.id_role).join(
        TZprospect, corZpObs.c.indexzp == TZprospect.indexzp)

    data = q.all()
    if data:
        tab_orga = []
        for d in data:
            info_orga = dict()
            info_orga['nom_organisme'] = str(d[0])
            tab_orga.append(info_orga)
        return tab_orga
    return None

@blueprint.route('/communes', methods=['GET'])
@json_resp
def get_commune():
    '''
    Retourne toutes les communes présentes dans le module
    '''

    q = DB.session.query(LAreas.area_name).distinct().join(
        corZpArea, LAreas.id_area == corZpArea.c.id_area).join(
        TZprospect, TZprospect.indexzp == corZpArea.c.indexzp)

    data = q.all()
    if data:
        tab_commune = []
        for d in data:
            nom_com = dict()
            nom_com['nom_commune'] = str(d[0])
            tab_commune.append(nom_com)
        return tab_commune
    return None

@blueprint.route('/taxs', methods=['GET'])
@json_resp
def get_taxons():
    '''
    Retourne tous les taxons présents dans le module
    '''

    q = DB.session.query(Taxref.nom_complet).distinct().join(TZprospect, TZprospect.cd_nom == Taxref.cd_nom)

    data = q.all()
    if data:
        taxons = []
        for d in data:
            taxon = dict()
            taxon['nom_complet'] = str(d[0])
            taxons.append(taxon)
        return taxons
    return None

@blueprint.route('/sites', methods=['GET'])
@json_resp
def get_all_sites():
    '''
    Retourne toutes les zones de prospection
    '''
    parameters = request.args

    q = (
        DB.session.query(
            TInfosSite,
            func.max(TBaseVisits.visit_date_min),
            Habref.lb_hab_fr_complet,
            func.count(distinct(TBaseVisits.id_base_visit)),
            func.string_agg(distinct(BibOrganismes.nom_organisme), ', '),
            func.string_agg(LAreas.area_name, ', ')
            ).outerjoin(
            TBaseVisits, TBaseVisits.id_base_site == TInfosSite.id_base_site
            # get habitat cd_hab
            ).outerjoin(
                Habref, TInfosSite.cd_hab == Habref.cd_hab
            # get organisms of a site
            ).outerjoin(
                corVisitObserver, corVisitObserver.c.id_base_visit == TBaseVisits.id_base_visit
            ).outerjoin(
                User, User.id_role == corVisitObserver.c.id_role
            ).outerjoin(
                BibOrganismes, BibOrganismes.id_organisme == User.id_organisme
            )
            # get municipalities of a site
            .outerjoin(
                corSiteArea, corSiteArea.c.id_base_site == TInfosSite.id_base_site
            ).outerjoin(
                LAreas, and_(LAreas.id_area == corSiteArea.c.id_area, LAreas.id_type == id_type_commune)
            )
            .group_by(
                TInfosSite, Habref.lb_hab_fr_complet
            )
        )


    
    if 'indexzp' in parameters:
        q = q.filter(TZprospect.indexzp == parameters['indexzp'])

    if 'organisme' in parameters:
        q = q.filter(BibOrganismes.nom_organisme == parameters['organisme'])

    if 'commune' in parameters:
        q = q.filter(LAreas.area_name == parameters['commune'])

    page = request.args.get('page', 1, type=int)
    items_per_page = blueprint.config['items_per_page']
    pagination_serverside = blueprint.config['pagination_serverside']

    if (pagination_serverside):
        pagination = q.paginate(page, items_per_page, False)
        data = pagination.items
        totalItmes = pagination.total
    else:
        totalItmes = 0
        data = q.all()

    pageInfo= {
        'totalItmes' : totalItmes,
        'items_per_page' : items_per_page,
    }
    features = []

    if data:
        for d in data:
            feature = d[0].get_geofeature()
            id_site = feature['properties']['indexzp']
            base_site_code = feature['properties']['t_zprospect']['base_site_code']
            base_site_description = feature['properties']['t_base_site']['base_site_description'] or 'Aucune description'
            base_site_name = feature['properties']['t_base_site']['base_site_name']
            if feature['properties']['t_base_site']:
                del feature['properties']['t_base_site']
            features.append(feature)

        return [pageInfo,FeatureCollection(features)]
    return None