from sqlalchemy import ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import UUID, JSONB
from geoalchemy2 import Geometry
from pypnusershub.db.models import User

from apptax.taxonomie.models import Taxref
from pypnnomenclature.models import TNomenclatures
from utils_flask_sqla.serializers import serializable
from utils_flask_sqla_geo.serializers import geoserializable, geofileserializable

from geonature.core.gn_meta.models import TDatasets
from geonature.core.ref_geo.models import LAreas
from geonature.utils.env import db

class ZpCruvedAuth(db.Model):
    """
    Classe abstraite de contrôle d'accès à la donnée
    """

    __abstract__ = True

    def user_is_observer(self, user):
        for obs in self.observers:
            if obs.id_role == user.id_role:
                return True
        return False

    def user_is_in_organism_of_zp(self, user):
        for obs in self.observers:
            if obs.id_role == user.id_role:
                return True
        return False

    def user_is_allowed_to(self, user, level):
        """
        Fonction permettant de dire si un utilisateur
        peu ou non agir sur une donnée
        """
        # Si l'utilisateur n'a pas de droit d'accès aux données
        if level == "0" or level not in ("1", "2", "3"):
            return False

        # Si l'utilisateur à le droit d'accéder à toutes les données
        if level == "3":
            return True

        # Si l'utilisateur est propriétaire de la données
        if self.user_is_observer(user):
            return True

        # Si l'utilisateur appartient à un organisme
        # qui a un droit sur la données et
        # que son niveau d'accès est 2 ou 3
        if self.user_is_in_organism_of_zp(user) and level in ("2", "3"):
            return True
        return False

    def get_model_cruved(self, user, user_cruved):
        """
        Return the user's cruved for a model instance.
        Use in the map-list interface to allow or not an action
        params:
            - user : a TRole object
            - user_cruved: object return by cruved_for_user_in_app(user)
        """
        return {
            action: self.user_is_allowed_to(user, level) for action, level in user_cruved.items()
        }


@serializable
class CorApPerturb(db.Model):
    __tablename__ = "cor_ap_perturb"
    __table_args__ = {"schema": "pr_priority_flora"}

    id_ap = db.Column(
        db.ForeignKey("pr_priority_flora.t_apresence.id_ap"),
        primary_key=True,
    )
    id_nomenclature = db.Column(
        db.ForeignKey("ref_nomenclatures.t_nomenclatures.id_nomenclature"),
        primary_key=True,
    )
    effective_presence = db.Column(db.Boolean)

    t_nomenclature = db.relationship(
        TNomenclatures,
        primaryjoin=id_nomenclature == TNomenclatures.id_nomenclature,
        foreign_keys=[id_nomenclature],
    )


@serializable
class CorApArea(db.Model):
    __tablename__ = "cor_ap_area"
    __table_args__ = {"schema": "pr_priority_flora"}

    id_area = db.Column(
        db.Integer,
        ForeignKey(LAreas.id_area),
        primary_key=True,
    )
    id_ap = db.Column(
        db.Integer,
        ForeignKey("TApresence.id_ap"),
        primary_key=True,
    )


@serializable
@geoserializable
class TApresence(db.Model):
    __tablename__ = "t_apresence"
    __table_args__ = {"schema": "pr_priority_flora"}

    id_ap = db.Column(db.Integer, primary_key=True, autoincrement=True)
    area = db.Column(db.Integer)
    topo_valid = db.Column(db.Boolean)
    altitude_min = db.Column(db.Integer)
    altitude_max = db.Column(db.Integer)
    frequency = db.Column(db.Integer)
    comment = db.Column(db.String(4000))
    id_zp = db.Column(
        db.ForeignKey("pr_priority_flora.t_zprospect.id_zp"),
        nullable=False,
    )
    id_nomenclature_incline = db.Column(db.Integer)
    id_nomenclature_counting = db.Column(db.Integer)
    id_nomenclature_habitat = db.Column(db.Integer)
    id_nomenclature_phenology = db.Column(db.Integer)
    id_history_action = db.Column(db.Integer)
    total_min = db.Column(db.Integer)
    total_max = db.Column(db.Integer)
    uuid_ap = db.Column(UUID(as_uuid=True))
    additional_data = db.Column(JSONB)
    geom_local = db.Column(Geometry("GEOMETRY"))
    geom_4326 = db.Column(Geometry("GEOMETRY", 4326))
    geom_point_4326 = db.Column(Geometry("POINT", 4326))
    meta_create_date = db.Column(db.DateTime)
    meta_update_date = db.Column(db.DateTime)

    cor_ap_perturbation = db.relationship(
        TNomenclatures,
        secondary=CorApPerturb.__table__,
        primaryjoin=(CorApPerturb.id_ap == id_ap),
        secondaryjoin=(CorApPerturb.id_nomenclature == TNomenclatures.id_nomenclature),
        foreign_keys=[CorApPerturb.id_ap, CorApPerturb.id_nomenclature],
    )
    incline = db.relationship(
        TNomenclatures,
        primaryjoin=(TNomenclatures.id_nomenclature == id_nomenclature_incline),
        foreign_keys=[id_nomenclature_incline],
    )
    pheno = db.relationship(
        TNomenclatures,
        primaryjoin=(TNomenclatures.id_nomenclature == id_nomenclature_phenology),
        foreign_keys=[id_nomenclature_phenology],
    )
    habitat = db.relationship(
        TNomenclatures,
        primaryjoin=(TNomenclatures.id_nomenclature == id_nomenclature_habitat),
        foreign_keys=[id_nomenclature_habitat],
    )
    counting = db.relationship(
        TNomenclatures,
        primaryjoin=(TNomenclatures.id_nomenclature == id_nomenclature_counting),
        foreign_keys=[id_nomenclature_counting],
    )

    def get_geofeature(self, fields=[]):
        return self.as_geofeature(
            "geom_4326",
            "id_ap",
            fields=fields,
        )


cor_zp_observer = db.Table(
    "cor_zp_obs",
    db.Column("id_role", ForeignKey(User.id_role), primary_key=True),
    db.Column("id_zp"),
    schema="pr_priority_flora",
)

cor_zp_area = db.Table(
    "cor_zp_area",
    db.Column("id_area", ForeignKey(LAreas.id_area), primary_key=True),
    db.Column("id_zp", primary_key=True),
    schema="pr_priority_flora",
)


@serializable
@geoserializable
class TZprospect(ZpCruvedAuth):
    __tablename__ = "t_zprospect"
    __table_args__ = {"schema": "pr_priority_flora"}

    id_zp = db.Column(db.Integer, primary_key=True, autoincrement=True)
    date_min = db.Column(db.DateTime)
    date_max = db.Column(db.DateTime)
    topo_valid = db.Column(db.Unicode)
    initial_insert = db.Column(db.Unicode)
    cd_nom = db.Column(
        db.ForeignKey(Taxref.cd_nom, onupdate="CASCADE"),
        nullable=False,
    )
    id_dataset = db.Column(
        db.ForeignKey(TDatasets.id_dataset, onupdate="CASCADE"),
    )
    uuid_zp = db.Column(UUID(as_uuid=True))
    additional_data = db.Column(JSONB)
    geom_local = db.Column(Geometry("GEOMETRY"))
    geom_4326 = db.Column(Geometry("GEOMETRY", 4326))
    geom_point_4326 = db.Column(Geometry("POINT", 4326))
    meta_create_date = db.Column(db.DateTime)
    meta_update_date = db.Column(db.DateTime)

    taxonomy = db.relationship(
        Taxref,
        primaryjoin=(cd_nom == Taxref.cd_nom),
        lazy="joined",
    )
    ap = relationship(
        "TApresence",
        lazy="select",
        uselist=True,
        cascade="all, delete-orphan",
    )
    observers = db.relationship(
        "User",
        lazy="joined",
        secondary=cor_zp_observer,
        primaryjoin=(cor_zp_observer.c.id_zp == id_zp),
        secondaryjoin=(cor_zp_observer.c.id_role == User.id_role),
        foreign_keys=[cor_zp_observer.c.id_zp, cor_zp_observer.c.id_role],
    )
    areas = db.relationship(
        LAreas,
        secondary=cor_zp_area,
        primaryjoin=(cor_zp_area.c.id_zp == id_zp),
        secondaryjoin=(cor_zp_area.c.id_area == LAreas.id_area),
        foreign_keys=[cor_zp_area.c.id_zp, cor_zp_area.c.id_area],
        lazy="joined",
    )

    def get_geofeature(self, fields=[]):
        return self.as_geofeature(
            "geom_4326",
            "id_zp",
            fields=fields,
        )


@serializable
@geoserializable
@geofileserializable
class ExportAp(db.Model):
    __tablename__ = "export_ap"
    __table_args__ = {"schema": "pr_priority_flora"}

    id_zp = db.Column(db.Integer, primary_key=True)
    id_ap = db.Column(db.Integer, primary_key=True)
    taxon = db.Column(db.Unicode)
    observateurs = db.Column(db.Unicode)
    habitat = db.Column(db.Unicode)
    pheno = db.Column(db.Unicode)
    pente = db.Column(db.Unicode)
    comptage = db.Column(db.Unicode)
    total_min = db.Column(db.Integer)
    total_max = db.Column(db.Integer)
    type_perturbation = db.Column(db.Unicode)
    frequence = db.Column(db.Integer)
    remarques = db.Column(db.Unicode)
    secteur = db.Column(db.Unicode)
    date_min = db.Column(db.DateTime)
    date_max = db.Column(db.DateTime)
    altitude_min = db.Column(db.Integer)
    altitude_max = db.Column(db.Integer)
    surface_ap = db.Column(db.Integer)
    surface_zp = db.Column(db.Integer)
    ap_geom_local = db.Column(Geometry("GEOMETRY"))
    zp_geom_local = db.Column(Geometry("GEOMETRY"))

    def get_geofeature(self, fields=[]):
        return self.as_geofeature(
            "ap_geom_local",
            "id_ap",
            fields=fields,
        )
