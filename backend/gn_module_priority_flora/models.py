from geonature.core.utils import ModelCruvedAutorization
from sqlalchemy import ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import UUID
from geoalchemy2 import Geometry
from pypnusershub.db.models import User

from geonature.utils.env import DB
from geonature.utils.config import config

from utils_flask_sqla.serializers import serializable
from utils_flask_sqla_geo.serializers import geoserializable, geofileserializable

from geonature.core.ref_geo.models import LAreas
from pypnnomenclature.models import TNomenclatures
from apptax.taxonomie.models import Taxref


class ZpCruvedAuth(DB.Model):
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
            action: self.user_is_allowed_to(user, level)
            for action, level in user_cruved.items()
        }

@serializable
class CorApPerturb(DB.Model):
    __tablename__ = "cor_ap_perturb"
    __table_args__ = {"schema": "pr_priority_flora"}

    id_ap = DB.Column(
        DB.ForeignKey("pr_priority_flora.t_apresence.id_ap", onupdate="CASCADE"),
        primary_key=True,
        nullable=False,
    )
    id_nomenclature = DB.Column(
        DB.ForeignKey(
            "ref_nomenclatures.t_nomenclatures.id_nomenclature", onupdate="CASCADE"
        ),
        primary_key=True,
        nullable=False,
    )
    effective_presence = DB.Column(DB.Boolean)

    t_nomenclature = DB.relationship(
        TNomenclatures,
        primaryjoin=id_nomenclature == TNomenclatures.id_nomenclature,
        foreign_keys=[id_nomenclature],
    )



@serializable
class CorApArea(DB.Model):
    __tablename__ = "cor_ap_area"
    __table_args__ = {"schema": "pr_priority_flora"}

    id_area = DB.Column(DB.Integer, ForeignKey(LAreas.id_area), primary_key=True)
    id_ap = DB.Column(DB.Integer, ForeignKey("TApresence.id_ap"), primary_key=True)


@serializable
@geoserializable
class TApresence(DB.Model):
    __tablename__ = "t_apresence"
    __table_args__ = {"schema": "pr_priority_flora"}
    id_ap = DB.Column(DB.Integer, primary_key=True, autoincrement=True)
    id_zp = DB.Column(
        DB.ForeignKey("pr_priority_flora.t_zprospect.id_zp"), nullable=False
    )
    altitude_min = DB.Column(DB.Integer)
    altitude_max = DB.Column(DB.Integer)
    area = DB.Column(DB.Integer)
    id_nomenclature_incline = DB.Column(DB.Integer)
    id_nomenclature_phenology = DB.Column(DB.Integer)
    id_nomenclature_habitat = DB.Column(DB.Integer)
    frequency = DB.Column(DB.Integer)
    id_nomenclature_counting = DB.Column(DB.Integer)
    total_min = DB.Column(DB.Integer)
    total_max = DB.Column(DB.Integer)
    comment = DB.Column(DB.String(4000))
    geom_4326 = DB.Column(Geometry("GEOMETRY", 4326))

    cor_ap_perturbation = DB.relationship(
        TNomenclatures,
        secondary=CorApPerturb.__table__,
        primaryjoin=(CorApPerturb.id_ap == id_ap),
        secondaryjoin=(CorApPerturb.id_nomenclature == TNomenclatures.id_nomenclature),
        foreign_keys=[CorApPerturb.id_ap, CorApPerturb.id_nomenclature],
    )
    incline = DB.relationship(
        TNomenclatures,
        primaryjoin=(TNomenclatures.id_nomenclature == id_nomenclature_incline),
        foreign_keys=[id_nomenclature_incline],
    )

    pheno = DB.relationship(
        TNomenclatures,
        primaryjoin=(TNomenclatures.id_nomenclature == id_nomenclature_phenology),
        foreign_keys=[id_nomenclature_phenology],
    )

    habitat = DB.relationship(
        TNomenclatures,
        primaryjoin=(TNomenclatures.id_nomenclature == id_nomenclature_habitat),
        foreign_keys=[id_nomenclature_habitat],
    )

    counting = DB.relationship(
        TNomenclatures,
        primaryjoin=(TNomenclatures.id_nomenclature == id_nomenclature_counting),
        foreign_keys=[id_nomenclature_counting],
    )

    def get_geofeature(self, columns=[], recursif=True):
        return self.as_geofeature("geom_4326", "id_ap", recursif)


# @serializable
# class CorZpObs(DB.Model):
#     __tablename__ = "cor_zp_obs"
#     __table_args__ = {"schema": "priority_flora"}

#     id_role = DB.Column(DB.Integer, ForeignKey(User.id_role), primary_key=True)
#     id_zp = DB.Column(DB.Integer, ForeignKey("TZprospect.id_zp"), primary_key=True)


cor_zp_observer = DB.Table('cor_zp_obs',
    DB.Column('id_role', ForeignKey(User.id_role), primary_key=True),
    DB.Column('id_zp'),
    schema="pr_priority_flora"
)

cor_zp_area = DB.Table('cor_zp_area',
    DB.Column('id_area', ForeignKey(LAreas.id_area), primary_key=True),
    DB.Column('id_zp', primary_key=True),
    schema="pr_priority_flora"
)

# @serializable
# class CorZpArea(DB.Model):
#     __tablename__ = "cor_zp_area"
#     __table_args__ = {"schema": "pr_priority_flora"}

#     id_area = DB.Column(DB.Integer, ForeignKey(LAreas.id_area), primary_key=True)
#     id_zp = DB.Column(DB.Integer, ForeignKey("TZprospect.id_zp"), primary_key=True)


@serializable
@geoserializable
class TZprospect(ZpCruvedAuth):
    __tablename__ = "t_zprospect"
    __table_args__ = {"schema": "pr_priority_flora"}
    id_zp = DB.Column(DB.Integer, primary_key=True, autoincrement=True)
    date_min = DB.Column(DB.DateTime)
    date_max = DB.Column(DB.DateTime)
    cd_nom = DB.Column(
        DB.ForeignKey(Taxref.cd_nom, onupdate="CASCADE"), nullable=False
    )
    topo_valid = DB.Column(DB.Unicode)
    initial_insert = DB.Column(DB.Unicode)
    geom_4326 = DB.Column(Geometry("GEOMETRY", 4326))
    taxonomy = DB.relationship(
        Taxref,
        primaryjoin=(cd_nom == Taxref.cd_nom),
        lazy="joined",
    )
    ap = relationship(
        "TApresence", lazy="select", uselist=True, cascade="all, delete-orphan"
    )
    observers = DB.relationship(
        "User",
        lazy="joined",
        secondary=cor_zp_observer,
        primaryjoin=(cor_zp_observer.c.id_zp == id_zp),
        secondaryjoin=(cor_zp_observer.c.id_role == User.id_role),
        foreign_keys=[cor_zp_observer.c.id_zp, cor_zp_observer.c.id_role],
    )
    areas = DB.relationship(
        LAreas,
        secondary=cor_zp_area,
        primaryjoin=(cor_zp_area.c.id_zp == id_zp),
        secondaryjoin=(cor_zp_area.c.id_area == LAreas.id_area),
        foreign_keys=[cor_zp_area.c.id_zp, cor_zp_area.c.id_area],
        lazy="joined"
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
class ExportAp(DB.Model):
    __tablename__ = "export_ap"
    __table_args__ = {"schema": "pr_priority_flora"}
    id_zp = DB.Column(DB.Integer, primary_key=True)
    id_ap = DB.Column(DB.Integer, primary_key=True)
    taxon = DB.Column(DB.Unicode)
    observateurs = DB.Column(DB.Unicode)
    habitat = DB.Column(DB.Unicode)
    pheno = DB.Column(DB.Unicode)
    pente = DB.Column(DB.Unicode)
    comptage = DB.Column(DB.Unicode)
    total_min = DB.Column(DB.Integer)
    total_max = DB.Column(DB.Integer)
    type_perturbation = DB.Column(DB.Unicode)
    frequence = DB.Column(DB.Integer)
    remarques = DB.Column(DB.Unicode)
    secteur = DB.Column(DB.Unicode)
    date_min = DB.Column(DB.DateTime)
    date_max = DB.Column(DB.DateTime)
    altitude_min = DB.Column(DB.Integer)
    altitude_max = DB.Column(DB.Integer)
    surface_ap = DB.Column(DB.Integer)
    surface_zp = DB.Column(DB.Integer)
    ap_geom_local = DB.Column(Geometry("GEOMETRY", config["LOCAL_SRID"]))
    zp_geom_local = DB.Column(Geometry("GEOMETRY", config["LOCAL_SRID"]))
