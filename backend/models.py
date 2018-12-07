from flask import current_app
from sqlalchemy import ForeignKey
from sqlalchemy.ext.associationproxy import association_proxy
from sqlalchemy.dialects.postgresql import UUID
from geoalchemy2 import Geometry


from geonature.utils.env import DB
from geonature.utils.utilssqlalchemy import (
    serializable,
    geoserializable,
    GenericQuery,
)
from geonature.utils.utilsgeometry import shapeserializable

@serializable
@geoserializable
class TZprospect(DB.Model):
    __tablename__ = 't_zprospect'
    __table_args__ = {'schema': 'pr_priority_flora'}
    indexzp = DB.Column(DB.Integer,primary_key=True)
    date_min = DB.Column(DB.DateTime)
    date_max = DB.Column(DB.DateTime)
    topo_valid = DB.Column(DB.Unicode)
    initial_insert  = DB.Column(DB.Unicode)
    cd_nom = DB.Column(DB.Integer)
    geom_4326 = DB.Column(Geometry('GEOMETRY', 4326))


@serializable
class CorZpObs(DB.Model):
    __tablename__ = 'cor_zp_obs'
    __table_args__ = {'schema': 'pr_priority_flora'}
    indexzp = DB.Column(DB.Integer, primary_key=True)
    id_role = DB.Column(DB.Integer, primary_key=True)

@serializable
class CorZpArea(DB.Model):
    __tablename__ = 'cor_zp_area'
    __table_args__ = {'schema': 'pr_priority_flora'}
    indexzp = DB.Column(DB.Integer, primary_key=True)
    id_area = DB.Column(DB.Integer, primary_key=True)