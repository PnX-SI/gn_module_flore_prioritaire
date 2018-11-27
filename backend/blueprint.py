from flask import Blueprint

from geonature.utils.env import DB
from geonature.utils.utilssqlalchemy import json_resp
from .models import TPrograms

blueprint = Blueprint('pr_priority_flora', __name__)

@blueprint.route('/test', methods=['GET', 'POST'])
def test():
    return 'It works'


