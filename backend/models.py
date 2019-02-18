from flask import current_app
from sqlalchemy import ForeignKey
from sqlalchemy.ext.associationproxy import association_proxy
from sqlalchemy.dialects.postgresql import UUID
from geoalchemy2 import Geometry
from pypnusershub.db.models import User

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
    indexzp = DB.Column(DB.ForeignKey(
        'pr_priority_flora.t_zprospect.indexzp'), nullable=False)
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

corApArea = DB.Table(
    'cor_ap_area',
    DB.MetaData(schema='pr_priority_flora'),
    DB.Column(
        'indexap',
        DB.Integer,
        ForeignKey('pr_priority_flora.t_apresence.indexap'),
        primary_key=True
    ),
    DB.Column(
        'id_area',
        DB.Integer,
        ForeignKey('ref_geo.l_areas.id_area'),
        primary_key=True
    )
)

corApPerturb = DB.Table(
    'cor_ap_perturb',
    DB.MetaData(schema='pr_priority_flora'),
    DB.Column(
        'indexap',
        DB.Integer,
        ForeignKey('pr_priority_flora.t_apresence.indexap'),
        primary_key=True
    ),
    DB.Column(
        'id_nomenclature',
        DB.Integer,
        ForeignKey('ref_nomenclatures.t_nomenclatures.id_nomenclature'),
        primary_key=True
    )
)

corApPhysio = DB.Table(
    'cor_ap_physionomie',
    DB.MetaData(schema='pr_priority_flora'),
    DB.Column(
        'indexap',
        DB.Integer,
        ForeignKey('pr_priority_flora.t_apresence.indexap'),
        primary_key=True
    ),
    DB.Column(
        'id_nomenclature',
        DB.Integer,
        ForeignKey('ref_nomenclatures.t_nomenclatures.id_nomenclature'),
        primary_key=True
    )
)

corZpArea = DB.Table(
    'cor_zp_area',
    DB.MetaData(schema='pr_priority_flora'),
    DB.Column(
        'indexzp',
        DB.Integer,
        ForeignKey('pr_priority_flora.t_zprospect.indexzp'),
        primary_key=True
    ),
    DB.Column(
        'id_area',
        DB.Integer,
        ForeignKey('ref_geo.l_areas.id_area'),
        primary_key=True
    )
)

corZpObs = DB.Table(
    'cor_zp_obs',
    DB.MetaData(schema='pr_priority_flora'),
    DB.Column(
        'indexzp',
        DB.Integer,
        ForeignKey('pr_priority_flora.t_zprospect.indexzp'),
        primary_key=True
    ),
    DB.Column(
        'id_role',
        DB.Integer,
        ForeignKey('utilisateurs.t_roles.id_role'),
        primary_key=True
    )
)