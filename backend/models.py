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
    cd_nom = DB.Column(DB.Integer)
    topo_valid = DB.Column(DB.Unicode)
    initial_insert  = DB.Column(DB.Unicode)
    geom_4326 = DB.Column(Geometry('GEOMETRY', 4326))


@serializable
@geoserializable
class TApresence(DB.Model):
    __tablename__ = 't_apresence'
    __table_args__ = {'schema': 'pr_priority_flora'}
    indexap = DB.Column(DB.Integer,primary_key=True)
    topo_valid = DB.Column(DB.Unicode)
    initial_insert  = DB.Column(DB.Unicode)
    altitude_min = DB.Column(DB.Integer)
    altitude_max = DB.Column(DB.Integer)
    nb_transects_frequency = DB.Column(DB.Integer)
    nb_points_frequency = DB.Column(DB.Integer)
    nb_contacts_frequency = DB.Column(DB.Integer)
    nb_plots_count = DB.Column(DB.Integer)
    nb_sterile_plots = DB.Column(DB.Integer)
    total_fertile = DB.Column(DB.Integer)
    total_sterile = DB.Column(DB.Integer)
    geom_4326 = DB.Column(Geometry('GEOMETRY', 4326))


