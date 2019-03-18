from flask import current_app
from sqlalchemy import ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.ext.associationproxy import association_proxy
from sqlalchemy.dialects.postgresql import UUID
from geoalchemy2 import Geometry
from pypnusershub.db.models import User

from geonature.utils.env import DB
from geonature.utils.utilssqlalchemy import serializable, geoserializable, GenericQuery
from geonature.utils.utilsgeometry import shapeserializable

from geonature.core.taxonomie.models import Taxref
from geonature.core.ref_geo.models import LAreas
from geonature.core.users.models import BibOrganismes
from pypnnomenclature.models import TNomenclatures


@serializable
@geoserializable
class TApresence(DB.Model):
    __tablename__ = "t_apresence"
    __table_args__ = {"schema": "pr_priority_flora"}
    indexap = DB.Column(DB.Integer, primary_key=True)
    indexzp = DB.Column(
        DB.ForeignKey("pr_priority_flora.t_zprospect.indexzp"), nullable=False
    )
    topo_valid = DB.Column(DB.Unicode)
    frequency = DB.Column(DB.Unicode)
    altitude_min = DB.Column(DB.Integer)
    altitude_max = DB.Column(DB.Integer)
    nb_transects_frequency = DB.Column(DB.Integer)
    nb_points_frequency = DB.Column(DB.Integer)
    nb_contacts_frequency = DB.Column(DB.Integer)
    nb_plots_count = DB.Column(DB.Integer)
    nb_sterile_plots = DB.Column(DB.Integer)
    total_fertile = DB.Column(DB.Integer)
    total_sterile = DB.Column(DB.Integer)
    geom_4326 = DB.Column(Geometry("GEOMETRY", 4326))

    def get_geofeature(self, recursif=True):
        return self.as_geofeature("geom_4326", "indexap", recursif)


@serializable
@geoserializable
class TZprospect(DB.Model):
    __tablename__ = "t_zprospect"
    __table_args__ = {"schema": "pr_priority_flora"}
    indexzp = DB.Column(DB.Integer, primary_key=True)
    date_min = DB.Column(DB.DateTime)
    date_max = DB.Column(DB.DateTime)
    cd_nom = DB.Column(
        DB.ForeignKey(
            "taxonomie.taxref.cd_nom", ondelete="CASCADE", onupdate="CASCADE"
        ),
        nullable=False,
    )
    topo_valid = DB.Column(DB.Unicode)
    initial_insert = DB.Column(DB.Unicode)
    geom_4326 = DB.Column(Geometry("GEOMETRY", 4326))
    taxonomy = DB.relationship(
        "Taxref", primaryjoin="TZprospect.cd_nom == Taxref.cd_nom", backref="taxrefs"
    )
    cor_ap = relationship("TApresence", lazy="select", uselist=True)

    def get_geofeature(self, columns=[], recursif=True):
        return self.as_geofeature("geom_4326", "indexzp", recursif, columns=columns)


@serializable
class CorApArea(DB.Model):
    __tablename__ = "cor_ap_area"
    __table_args__ = {"schema": "pr_priority_flora"}

    id_area = DB.Column(DB.Integer, ForeignKey(LAreas.id_area), primary_key=True)
    indexap = DB.Column(DB.Integer, ForeignKey(TApresence.indexap), primary_key=True)


@serializable
class CorZpObs(DB.Model):
    __tablename__ = "cor_zp_obs"
    __table_args__ = {"schema": "pr_priority_flora"}

    id_role = DB.Column(DB.Integer, ForeignKey(User.id_role), primary_key=True)
    indexzp = DB.Column(DB.Integer, ForeignKey(TZprospect.indexzp), primary_key=True)


@serializable
class CorZpArea(DB.Model):
    __tablename__ = "cor_zp_area"
    __table_args__ = {"schema": "pr_priority_flora"}

    id_area = DB.Column(DB.Integer, ForeignKey(LAreas.id_area), primary_key=True)
    indexzp = DB.Column(DB.Integer, ForeignKey(TZprospect.indexzp), primary_key=True)


@serializable
class CorApPerturb(DB.Model):
    __tablename__ = "cor_ap_perturb"
    __table_args__ = {"schema": "pr_priority_flora"}

    indexap = DB.Column(
        DB.ForeignKey("pr_priority_flora.t_apresence.indexap", onupdate="CASCADE"),
        primary_key=True,
        nullable=False,
    )
    id_nomenclature_perturbation = DB.Column(
        DB.ForeignKey(
            "ref_nomenclatures.t_nomenclatures.id_nomenclature", onupdate="CASCADE"
        ),
        primary_key=True,
        nullable=False,
    )
    t_nomenclature = DB.relationship(
        TNomenclatures,
        primaryjoin=id_nomenclature_perturbation == TNomenclatures.id_nomenclature,
        foreign_keys=[id_nomenclature_perturbation],
    )


@serializable
class CorApPhysio(DB.Model):
    __tablename__ = "cor_ap_physionomie"
    __table_args__ = {"schema": "pr_priority_flora"}

    indexap = DB.Column(
        DB.ForeignKey("pr_priority_flora.t_apresence.indexap", onupdate="CASCADE"),
        primary_key=True,
        nullable=False,
    )
    id_nomenclature_physionomie = DB.Column(
        DB.ForeignKey(
            "ref_nomenclatures.t_nomenclatures.id_nomenclature", onupdate="CASCADE"
        ),
        primary_key=True,
        nullable=False,
    )
    t_nomenclature = DB.relationship(
        TNomenclatures,
        primaryjoin=id_nomenclature_physionomie == TNomenclatures.id_nomenclature,
        foreign_keys=[id_nomenclature_physionomie],
    )

