from flask import Blueprint,request

from shapely.geometry import asShape
from geoalchemy2.shape import from_shape
from geojson import FeatureCollection

from geonature.utils.env import DB
from geonature.utils.utilssqlalchemy import (
    json_resp,
    GenericTable
)

from .models import TZprospect, TApresence
from  geonature.core.taxonomie.models import Taxref

blueprint = Blueprint('pr_priority_flora', __name__)

@blueprint.route('/z_prospects', methods=['GET'])
@json_resp
def get_zprospect():
    '''
    Retourne toutes les zones de prospections du module
    '''
    parameters = request.args
    q = (
        DB.session.query(
        TZprospect,
        Taxref
        ).join(
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
    
