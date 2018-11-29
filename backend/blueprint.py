from flask import Blueprint,request

from geonature.utils.env import DB
from geonature.utils.utilssqlalchemy import json_resp
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


