from flask import Blueprint, request

from shapely.geometry import asShape
from geoalchemy2.shape import from_shape
from geojson import FeatureCollection
from sqlalchemy.sql.expression import func
from sqlalchemy import and_, distinct, desc

from geonature.utils.env import DB
from geonature.utils.utilssqlalchemy import json_resp, GenericTable
from pypnnomenclature.models import TNomenclatures
from pypnusershub.db.models import User
from .models import TZprospect, TApresence, CorApArea, CorZpArea, CorApPerturb, CorZpObs
from geonature.core.taxonomie.models import Taxref
from geonature.core.ref_geo.models import LAreas
from geonature.core.users.models import BibOrganismes


blueprint = Blueprint("pr_priority_flora", __name__)


@blueprint.route("/z_prospects", methods=["GET"])
@json_resp
def get_zprospect():
    """
    Retourne toutes les zones de prospection du module
    """

    id_type_commune = blueprint.config["id_type_commune"]
    parameters = request.args
    q = (
        DB.session.query(TZprospect, Taxref, func.string_agg(LAreas.area_name, ", "))
        .outerjoin(Taxref, TZprospect.cd_nom == Taxref.cd_nom)
        .outerjoin(CorZpArea, CorZpArea.indexzp == TZprospect.indexzp)
        .outerjoin(CorZpObs, CorZpObs.indexzp == TZprospect.indexzp)
        .outerjoin(User, User.id_role == CorZpObs.id_role)
        .outerjoin(BibOrganismes, BibOrganismes.id_organisme == User.id_organisme)
        .outerjoin(
            LAreas,
            and_(
                LAreas.id_area == CorZpArea.id_area, LAreas.id_type == id_type_commune
            ),
        )
        .group_by(TZprospect, Taxref)
    )
    if "indexzp" in parameters:
        q = q.filter(TZprospect.indexzp == parameters["indexzp"])

    if "cd_nom" in parameters:
        q = q.filter(Taxref.cd_nom == parameters["cd_nom"])

    if "commune" in parameters:
        q = q.filter(LAreas.area_name == parameters["commune"])

    if "organisme" in parameters:
        q = q.filter(BibOrganismes.nom_organisme == parameters["organisme"])

    if "year" in parameters:
        q = q.filter(func.date_part("year", TZprospect.date_min) == parameters["year"])

    data = q.all()
    features = []

    for d in data:
        feature = d[0].get_geofeature(
            recursif=False, columns=["indexzp", "date_min", "date_max", "cd_nom"]
        )
        id_zp = feature["properties"]["indexzp"]
        feature["properties"]["taxon"] = d[1].as_dict(["nom_valide"])
        features.append(feature)
    return FeatureCollection(features)


@blueprint.route("/apresences", methods=["GET"])
@json_resp
def get_apresences():
    """
    Retourne toutes les aires de présence d'une zone de prospection
    """
    parameters = request.args
    q = DB.session.query(TApresence, TZprospect).outerjoin(
        TZprospect, TApresence.indexzp == TZprospect.indexzp
    )
    if "indexzp" in parameters:
        q = q.filter(TApresence.indexzp == parameters["indexzp"])
    data = q.all()
    features = []

    for d in data:
        feature = d[0].get_geofeature()
        id_ap = feature["properties"]["indexap"]
        features.append(feature)

    return FeatureCollection(features)


@blueprint.route("/post_zp", methods=["POST"])
@blueprint.route("/post_zp/<int:id_zp>", methods=["POST"])
@json_resp
def post_zp(id_zp=None):
    """
    Poste une nouvelle zone de prospection
    """
    data = dict(request.get_json())

    if data["indexzp"] is None:
        data.pop("indexzp")

    tab_observer = []

    if "cor_zp_observer" in data:
        tab_observer = data.pop("cor_zp_observer")

    shape = asShape(data["geom_4326"])
    releve = TZprospect(**data)
    releve.geom_4326 = from_shape(shape, srid=4326)

    cor_zp_observer = (
        DB.session.query(User).filter(User.id_role.in_(tab_observer)).all()
    )

    for o in cor_zp_observer:
        releve.cor_zp_observer.append(o)
    if "indexzp" in data:
        DB.session.merge(releve)
    else:
        DB.session.add(releve)
    DB.session.flush()

    DB.session.commit()

    return releve.as_geofeature("geom_4326", "indexzp", True)


@blueprint.route("/post_ap", methods=["POST"])
@json_resp
def post_ap():
    """
    Poste une nouvelle aire de présence
    """
    data = dict(request.get_json())
    tab_pertu = []
    if data["indexap"] is None:
        data.pop("indexap")

    if "cor_ap_perturbation" in data:
        tab_pertu = data.pop("cor_ap_perturbation")

    shape = asShape(data.pop("geom_4326"))
    ap = TApresence(**data)
    ap.geom_4326 = from_shape(shape, srid=4326)
    print(data)
    cor_ap_pertubation = (
        DB.session.query(TNomenclatures)
        .filter(
            TNomenclatures.id_nomenclature.in_(
                [pert["id_nomenclature"] for pert in tab_pertu]
            )
        )
        .all()
    )

    for o in cor_ap_pertubation:
        ap.cor_ap_perturbation.append(o)

    # TODO: manque indexzp
    if "indexap" in data:
        DB.session.merge(ap)
    else:
        DB.session.add(ap)
    DB.session.commit()

    return ap.as_geofeature("geom_4326", "indexap", True)


@blueprint.route("/organismes", methods=["GET"])
@json_resp
def get_organisme():
    """
    Retourne la liste de tous les organismes présents
    """

    q = (
        DB.session.query(BibOrganismes.nom_organisme)
        .distinct()
        .join(User, BibOrganismes.id_organisme == User.id_organisme)
        .join(CorZpObs, User.id_role == CorZpObs.id_role)
        .join(TZprospect, CorZpObs.indexzp == TZprospect.indexzp)
    )

    data = q.all()
    if data:
        tab_orga = []
        for d in data:
            info_orga = dict()
            info_orga["nom_organisme"] = str(d[0])
            tab_orga.append(info_orga)
        return tab_orga
    return None


@blueprint.route("/communes", methods=["GET"])
@json_resp
def get_commune():
    """
    Retourne toutes les communes présentes dans le module
    """

    q = (
        DB.session.query(LAreas.area_name)
        .distinct()
        .join(CorZpArea, LAreas.id_area == CorZpArea.id_area)
        .join(TZprospect, TZprospect.indexzp == CorZpArea.indexzp)
    )

    data = q.all()
    if data:
        tab_commune = []
        for d in data:
            nom_com = dict()
            nom_com["nom_commune"] = str(d[0])
            tab_commune.append(nom_com)
        return tab_commune
    return None


@blueprint.route("/sites", methods=["GET"])
@json_resp
def get_all_sites():
    """
    Retourne toutes les zones de prospection
    """
    parameters = request.args
    q = DB.session.query(TZprospect, Taxref).outerjoin(
        Taxref, TZprospect.cd_nom == Taxref.cd_nom
    )
    if "indexzp" in parameters:
        q = q.filter(TZprospect.indexzp == parameters["indexzp"])

    if "cd_nom" in parameters:
        q = q.filter(Taxref.cd_nom == parameters["cd_nom"])

    data = q.all()
    features = []
    for d in data:
        feature = d[0].as_geofeature("geom_4326", "indexzp", True)
        id_zp = feature["properties"]["indexzp"]
        feature["properties"]["taxon"] = d[1].as_dict()
        features.append(feature)

    return FeatureCollection(features)


#  route get One Zp
@blueprint.route("/zp/<int:id_zp>", methods=["GET"])
@json_resp
def get_one_zp(id_zp):

    zp = DB.session.query(TZprospect).get(id_zp)

    if zp:
        return {
            "aps": FeatureCollection([ap.get_geofeature() for ap in zp.cor_ap]),
            "zp": FeatureCollection([zp.get_geofeature()]),
        }
    return None


#  route get One Ap
@blueprint.route("/ap/<int:id_ap>", methods=["GET"])
@json_resp
def get_one_ap(id_ap):

    ap = DB.session.query(TApresence).get(id_ap)

    return ap.get_geofeature()


#  route get One Zp
@blueprint.route("/zp/<int:id_zp>", methods=["DELETE"])
@json_resp
def delete_one_zp(id_zp):

    zp = DB.session.query(TZprospect).get(id_zp)

    if zp:
        DB.session.delete(zp)
        DB.session.commit()
        return {"message": "delete with success"}, 200
    return None


@blueprint.route("/ap/<int:id_ap>", methods=["DELETE"])
@json_resp
def delete_one_ap(id_ap):

    ap = DB.session.query(TApresence).get(id_ap)
    if ap:
        DB.session.delete(ap)
        DB.session.commit()
        return {"message": "delete with success"}, 200
    return None
