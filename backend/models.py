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

from geonature.core.taxonomie.models import Taxref
from geonature.core.ref_geo.models import LAreas
from geonature.core.users.models import BibOrganismes
from pypnnomenclature.models import TNomenclatures

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

    def get_geofeature(self, recursif=True):
        return self.as_geofeature(
            'geom_4326',
            'indexzp',
            recursif
        )

@serializable
@geoserializable
class TApresence(DB.Model):
    __tablename__ = 't_apresence'
    __table_args__ = {'schema': 'pr_priority_flora'}
    indexap = DB.Column(DB.Integer,primary_key=True)
    indexzp = DB.Column(DB.ForeignKey(
        'pr_priority_flora.t_zprospect.indexzp'), nullable=False)
    topo_valid = DB.Column(DB.Unicode)
    frequency  = DB.Column(DB.Unicode)
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

    def get_geofeature(self, recursif=True):
        return self.as_geofeature(
            'geom_4326',
            'indexap',
            recursif
        )

@serializable
class CorApArea(DB.Model):
    __tablename__ = 'cor_ap_area'
    __table_args__ = {'schema': 'pr_priority_flora'}

    id_area = DB.Column(
        DB.Integer,
        ForeignKey(LAreas.id_area),
        primary_key=True
    )
    indexap = DB.Column(
        DB.Integer,
        ForeignKey(TApresence.indexap),
        primary_key=True
    )

@serializable
class CorZpObs(DB.Model):
    __tablename__ = 'cor_zp_obs'
    __table_args__ = {'schema': 'pr_priority_flora'}

    id_role = DB.Column(
        DB.Integer,
        ForeignKey(User.id_role),
        primary_key=True
    )
    indexzp = DB.Column(
        DB.Integer,
        ForeignKey(TZprospect.indexzp),
        primary_key=True
    )

@serializable
class CorZpArea(DB.Model):
    __tablename__ = 'cor_zp_area'
    __table_args__ = {'schema': 'pr_priority_flora'}

    id_area = DB.Column(
        DB.Integer,
        ForeignKey(LAreas.id_area),
        primary_key=True
    )
    indexzp = DB.Column(
        DB.Integer,
        ForeignKey(TZprospect.indexzp),
        primary_key=True
    )

@serializable
class TNomenclature(DB.Model):
    __tablename__ = 't_nomenclatures'
    __table_args__ = {'schema': 'ref_nomenclatures', 'extend_existing': True}

    id_nomenclature = DB.Column(
        DB.Integer, primary_key=True, server_default=DB.FetchedValue())
    mnemonique = DB.Column(DB.String(255))
    label_default = DB.Column(DB.String(255), nullable=False)


@serializable
class CorApPerturb(DB.Model):
    __tablename__ = 'cor_ap_perturb'
    __table_args__ = {'schema': 'pr_priority_flora'}

    indexap = DB.Column(DB.ForeignKey(
        'pr_priority_flora.t_apresence.indexap', onupdate='CASCADE'), primary_key=True, nullable=False)
    id_nomenclature_perturbation = DB.Column(DB.ForeignKey(
        'ref_nomenclatures.t_nomenclatures.id_nomenclature', onupdate='CASCADE'), primary_key=True, nullable=False)
    t_nomenclature = DB.relationship(
        'TNomenclature', primaryjoin='CorApPerturb.id_nomenclature_perturbation == TNomenclature.id_nomenclature', backref='cor_ap_perturb')

@serializable
class CorApPhysio(DB.Model):
    __tablename__ = 'cor_ap_physionomie'
    __table_args__ = {'schema': 'pr_priority_flora'}

    indexap = DB.Column(DB.ForeignKey(
        'pr_priority_flora.t_apresence.indexap', onupdate='CASCADE'), primary_key=True, nullable=False)
    id_nomenclature_physionomie = DB.Column(DB.ForeignKey(
        'ref_nomenclatures.t_nomenclatures.id_nomenclature', onupdate='CASCADE'), primary_key=True, nullable=False)
    t_nomenclature = DB.relationship(
        'TNomenclature', primaryjoin='CorApPhysio.id_nomenclature_physionomie == TNomenclature.id_nomenclature', backref='cor_ap_physionomie')
