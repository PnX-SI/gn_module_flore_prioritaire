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
from .models import TZprospect, TApresence, CorApArea, CorZpArea, CorApPerturb, CorApPhysio, CorZpObs
from geonature.core.taxonomie.models import Taxref
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
        feature = d[0].get_geofeature()
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
    q = (
        DB.session.query(
        TApresence,
        TZprospect
        ).outerjoin(
            TZprospect, TApresence.indexzp == TZprospect.indexzp
        ))
    if 'indexzp' in parameters:
        q = q.filter(TApresence.indexzp == parameters['indexzp'])
    data = q.all()
    features = []

    for d in data:
        feature = d[0].get_geofeature()
        id_ap = feature['properties']['indexap']
        features.append(feature)
        
    return FeatureCollection(features)

@blueprint.route('/post_zp', methods=['POST'])
@json_resp
def post_visit():
    '''
    Poste une nouvelle zone de prospection
    '''
    data = dict(request.get_json())

    tab_observer = []

    if 'cor_visit_observer' in data:
        tab_observer = data.pop('cor_visit_observer')

    shape = asShape(data['geom_4326'])
    releve= TZprospect(**data)
    releve.geom_4326 = from_shape(shape, srid=4326)
    
    observers = DB.session.query(User).filter(
        User.id_role.in_(tab_observer)
    ).all()

    for o in observers:
        visit.observers.append(o)

    DB.session.add(releve)
    DB.session.commit()
    DB.session.flush()
    return releve.as_geofeature('geom_4326','indexzp',True)

@blueprint.route('/post_ap', methods=['POST'])
@json_resp
def post_ap():
    '''
    Poste une nouvelle aire de présence
    '''
    data = dict(request.get_json())

    shape = asShape(data['geom_4326'])
    releve= TApresence(**data)
    releve.geom_4326 = from_shape(shape, srid=4326)
    DB.session.add(releve)
    DB.session.commit()
    DB.session.flush()
    return releve.as_geofeature('geom_4326','indexap',True)
    

@blueprint.route('/organismes', methods=['GET'])
@json_resp
def get_organisme():
    '''
    Retourne la liste de tous les organismes présents
    '''

    q = DB.session.query(
        BibOrganismes.nom_organisme).distinct().join(
        User, BibOrganismes.id_organisme == User.id_organisme).join(
        corZpObs, User.id_role == CorZpObs.c.id_role).join(
        TZprospect, CorZpObs.c.indexzp == TZprospect.indexzp)

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