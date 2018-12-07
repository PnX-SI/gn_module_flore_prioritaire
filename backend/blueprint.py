from flask import Blueprint,request

from shapely.geometry import asShape
from geoalchemy2.shape import from_shape

from geonature.utils.env import DB
from geonature.utils.utilssqlalchemy import (
    json_resp,
    GenericTable
)
from .models import TZprospect

blueprint = Blueprint('pr_priority_flora', __name__)

@blueprint.route('/z_prospects', methods=['GET'])
@json_resp
def get_zprospect():
    '''
    Retourne toutes les zones de prospections du module
    '''
    parameters = request.args
    q = DB.session.query(TZprospect)
    if 'indexzp' in parameters:
        q = q.filter(TZprospect.indexzp == parameters['indexzp'])
    data = q.all()
    return [d.as_geofeature('geom_4326', 'indexzp') for d in data]

@blueprint.route('/form', methods=['POST'])
@json_resp
def post_visit():
    '''
    Poste une nouvelle visite ou éditer une ancienne
    '''
    data = dict(request.get_json())
    shape = asShape(data['geom_4326'])
    releve= TZprospect(**data)
    releve.geom_4326 = from_shape(shape, srid=4326)
    DB.session.add(releve)
    DB.session.commit()
    DB.session.flush()
    return releve.as_geofeature('geom_4326','indexzp',True)
    

