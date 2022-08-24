import datetime
import json
from operator import or_

from flask import Blueprint, request, jsonify
from geoalchemy2.shape import from_shape
from geojson import FeatureCollection
from shapely.geometry import asShape
from sqlalchemy.sql.expression import func, select
from sqlalchemy.sql.functions import user
from werkzeug.exceptions import Forbidden

from geonature.core.taxonomie.models import Taxref
from geonature.core.gn_permissions import decorators as permissions
from geonature.core.gn_permissions.tools import cruved_scope_for_user_in_module
from geonature.utils.env import db, ROOT_DIR
from pypnnomenclature.models import TNomenclatures
from pypnusershub.db.models import User
from pypnusershub.db.models import Organisme
from utils_flask_sqla.response import json_resp, to_json_resp, to_csv_resp

from .models import (
    TZprospect,
    TApresence,
    ExportAp,
    cor_zp_area
)


blueprint = Blueprint("priority_flora", __name__)


@blueprint.route("/prospect-zones", methods=["GET"])
@permissions.check_cruved_scope("R", True, module_code="priority_flora")
@json_resp
def get_prospect_zones(info_role):
    """
    Retourne toutes les zones de prospection du module
    """
    parameters = request.args
    page = int(parameters.get("page", 0))
    limit = int(parameters.get("limit", 100))
    user_cruved = cruved_scope_for_user_in_module(
        id_role=info_role.id_role, module_code="priority_flora"
    )
    query = TZprospect.query
    if info_role.value_filter == "2":
        query = query.filter(
                TZprospect.observers.any(or_(
                    User.id_role == info_role.id_role,
                    User.id_organisme == info_role.id_organisme,
                ))
        )
    if info_role.value_filter == "1":
        query = query.filter(
                TZprospect.observers.any(
                    User.id_role == info_role.id_role,
                )
        )
    if "id_zp" in parameters:
        query = query.filter(TZprospect.id_zp == parameters["id_zp"])

    if "cd_nom" in parameters:
        query = query.filter(TZprospect.taxonomy.has(cd_nom=parameters["cd_nom"]))

    if "id_area" in parameters:
        query = query.filter(TZprospect.areas.any(id_area=parameters["id_area"]))

    if "id_organism" in parameters:
        query = query.filter(TZprospect.observers.any(id_organisme=parameters["id_organism"]))

    if "year" in parameters:
        query = query.filter(func.date_part("year", TZprospect.date_min) == parameters["year"])
    filtered_number = query.count()
    data = query.order_by(TZprospect.date_min.desc()).limit(limit).offset(page * limit)
    features = []
    for d in data:
        feature = d.get_geofeature(
            fields=[
                "id_zp",
                "date_min",
                "date_max",
                "cd_nom",
                "taxonomy.nom_valide",
                "areas.area_name",
                "observers",
                "observers.organisme",
            ],
        )
        cruved_auth = d.get_model_cruved(info_role, user_cruved[0])
        feature["properties"]["rights"] = cruved_auth
        feature["properties"]["organisms_list"] = ", ".join(
            map(
                lambda obs: obs["organisme"]["nom_organisme"],
                feature["properties"]["observers"],
            )
        )
        features.append(feature)
    return {"total": filtered_number, "items": FeatureCollection(features)}


@blueprint.route("/presence-areas", methods=["GET"])
@permissions.check_cruved_scope("R", module_code="priority_flora")
@json_resp
def get_presence_areas():
    """
    Retourne toutes les aires de présence d'une zone de prospection
    """
    parameters = request.args
    page = int(parameters.get("page", 0))
    limit = int(parameters.get("limit", 100))

    query = db.session.query(TApresence)

    if "id_zp" in parameters:
        query = query.filter(TApresence.id_zp == parameters["id_zp"])

    data = (
        query
        .order_by(TApresence.meta_create_date.desc())
        .limit(limit)
        .offset(page * limit)
        .all()
    )

    features = []
    for d in data:
        feature = d.get_geofeature()
        features.append(feature)
    return FeatureCollection(features)


# TODO: handle id_zp when PUT used
@blueprint.route("/prospect-zones", methods=["POST"])
@blueprint.route("/prospect-zones/<int:id_zp>", methods=["PUT"])
@permissions.check_cruved_scope("C", True, module_code="priority_flora")
@json_resp
def edit_prospect_zone(info_role, id_zp=None):
    """
    Poste une nouvelle zone de prospection
    """
    data = dict(request.get_json())

    if id_zp is not None:
        data["id_zp"] = id_zp
    if data["id_zp"] is None:
        data.pop("id_zp")

    # TODO if no geom 4326 with POST send 400 BAD REQUEST
    shape = None
    if "geom_4326" in data:
        shape = asShape(data.pop("geom_4326"))

    observers = None
    if "cor_zp_observer" in data:
        observers = data.pop("cor_zp_observer")
        observers = db.session.query(User).filter(User.id_role.in_(observers)).all()

    if id_zp is not None:
        zp = db.session.query(TZprospect).filter_by(id_zp=id_zp).first()
    else:
        zp = TZprospect(**data)

    if shape is not None:
        zp.geom_4326 = from_shape(shape, srid=4326)

    if observers is not None:
        for o in observers:
            zp.observers.append(o)

    if "id_zp" in data:
        if info_role.value_filter in ("1", "2"):
            query = db.session.query(TZprospect).filter_by(id_zp=data["id_zp"])
            if info_role.value_filter == "2":
                query = query.filter(
                        TZprospect.observers.any(or_(
                            User.id_role == info_role.id_role,
                            User.id_organisme == info_role.id_organisme,
                        ))
                )
            if info_role.value_filter == "1":
                query = query.filter(
                        TZprospect.observers.any(
                            User.id_role == info_role.id_role,
                        )
                )
            check_cruved = db.session.query(query.exists()).scalar()
            if not check_cruved:
                raise Forbidden("Vous n'avez pas les droits pour éditer cette ZP")

        for key, value in data.items():
            if hasattr(zp, key):
                setattr(zp, key, value)

        db.session.merge(zp)
    else:
        db.session.add(zp)

    db.session.commit()
    db.session.flush()

    return zp.get_geofeature(fields=["observers"])


# TODO: handle id_ap when PUT used
@blueprint.route("/presence-areas", methods=["POST"])
@blueprint.route("/presence-areas/<int:id_ap>", methods=["PUT"])
@permissions.check_cruved_scope("C", True, module_code="priority_flora")
@json_resp
def add_presence_area(info_role, id_ap=None):
    """
    Poste une nouvelle aire de présence
    """
    data = dict(request.get_json())

    if id_ap is not None:
        data["id_ap"] = id_ap
    if data["id_ap"] is None:
        data.pop("id_ap")

    # TODO if no geom 4326 with POST send 400 BAD REQUEST
    shape = None
    if "geom_4326" in data:
        shape = asShape(data.pop("geom_4326"))

    perturbations = None
    if "cor_ap_perturbation" in data:
        perturbations = data.pop("cor_ap_perturbation")

    if id_ap is not None:
        ap = db.session.query(TApresence).filter_by(id_ap=id_ap).first()
    else:
        ap = TApresence(**data)

    if shape is not None:
        ap.geom_4326 = from_shape(shape, srid=4326)

    if perturbations is not None:
        cor_ap_pertubation = (
            db.session.query(TNomenclatures)
            .filter(
                TNomenclatures.id_nomenclature.in_(
                    [pert["id_nomenclature"] for pert in perturbations]
                )
            )
            .all()
        )
        for o in cor_ap_pertubation:
            ap.cor_ap_perturbation.append(o)

    if "id_ap" in data:
        if info_role.value_filter in ("1", "2"):
            query = db.session.query(TZprospect).filter_by(id_zp=data["id_zp"])
            if info_role.value_filter == "2":
                query = query.filter(
                        TZprospect.observers.any(or_(
                            User.id_role == info_role.id_role,
                            User.id_organisme == info_role.id_organisme,
                        ))
                )
            if info_role.value_filter == "1":
                query = query.filter(
                        TZprospect.observers.any(
                            User.id_role == info_role.id_role,
                        )
                )
            check_cruved = db.session.query(query.exists()).scalar()
            if not check_cruved:
                raise Forbidden("Vous n'avez pas les droits pour éditer cette AP")

        for key, value in data.items():
            if hasattr(ap, key):
                setattr(ap, key, value)

        db.session.merge(ap)
    else:
        db.session.add(ap)

    db.session.commit()
    db.session.flush()

    return ap.get_geofeature()


@blueprint.route("/organisms", methods=["GET"])
@json_resp
def get_organisme():
    """
    Retourne la liste de tous les organismes présents
    """
    query = """
        SELECT DISTINCT b.nom_organisme, b.id_organisme
        FROM utilisateurs.bib_organismes AS b
            JOIN utilisateurs.t_roles AS r
                ON r.id_organisme = b.id_organisme
            JOIN pr_priority_flora.cor_zp_obs AS c
                ON c.id_role = r.id_role
        ORDER by b.nom_organisme ASC
    """
    data = db.session.execute(query)

    if data:
        return [{"name": o[0], "id_organism": o[1]} for o in data]
    return { "message": "An error occured !" }, 500


@blueprint.route("/municipalities", methods=["GET"])
@json_resp
def get_commune():
    """
    Retourne toutes les communes présentes dans le module
    """
    query = """
        SELECT DISTINCT area_name, l.id_area
        FROM ref_geo.l_areas AS l
            JOIN pr_priority_flora.cor_ap_area AS ap
                ON ap.id_area = l.id_area
            JOIN ref_geo.bib_areas_types AS b
                ON b.id_type = l.id_type
        WHERE b.type_code = 'COM'
        ORDER BY area_name ASC
    """
    data = db.session.execute(query)

    if data:
        return [{"municipality": c[0], "id_area": c[1]} for c in data]
    return { "message": "An error occured !" }, 500


@blueprint.route("/prospect-zones/<id_zp>", methods=["GET"])
@permissions.check_cruved_scope("R", module_code="priority_flora")
@json_resp
def get_prospect_zone(id_zp):
    zp = db.session.query(TZprospect).get(id_zp)
    if zp:
        return {
            "aps": FeatureCollection([
                ap.get_geofeature(
                    fields=["cor_ap_perturbation", "incline", "pheno", "habitat", "counting"]
                )
                for ap in zp.ap
            ]),
            "zp": zp.get_geofeature(fields=["observers", "taxonomy", "areas", "areas.area_type"]),
        }
    return { "message": f"Prospect zone with ID {id_zp} not found !" }, 404


@blueprint.route("/presence-areas/<int:id_ap>", methods=["GET"])
@permissions.check_cruved_scope("R", module_code="priority_flora")
@json_resp
def get_presence_area(id_ap):
    ap = db.session.query(TApresence).get(id_ap)
    if ap:
        return ap.get_geofeature(
            fields=["cor_ap_perturbation", "incline", "pheno", "habitat", "counting"]
        )
    return { "message": f"Presence area with ID {id_ap} not found !" }, 404


@blueprint.route("/prospect-zones/<int:id_zp>", methods=["DELETE"])
@permissions.check_cruved_scope("D", module_code="priority_flora")
@json_resp
def delete_prospect_zone(id_zp):
    zp = db.session.query(TZprospect).get(id_zp)
    if zp:
        db.session.delete(zp)
        db.session.commit()
        return None, 204
    return {"message": f"Prospect zone with ID {id_zp} not found !"}, 404


@blueprint.route("/presence-areas/<int:id_ap>", methods=["DELETE"])
@permissions.check_cruved_scope("D", module_code="priority_flora")
@json_resp
def delete_presence_area(id_ap):
    ap = db.session.query(TApresence).get(id_ap)
    if ap:
        db.session.delete(ap)
        db.session.commit()
        return None, 204
    return {"message": f"Presence area with ID {id_ap} not found !"}, 404


@blueprint.route("/presence-areas/export", methods=["GET"])
@permissions.check_cruved_scope("E", module_code="priority_flora")
def export_presence_areas():
    """
    Télécharge les données d'une aire de présence
    """
    parameters = request.args

    export_format = (
        parameters["export_format"] if "export_format" in request.args else "geojson"
    )

    file_name = datetime.datetime.now().strftime("%Y_%m_%d_%Hh%Mm%S")
    query = db.session.query(ExportAp)

    if "id_ap" in parameters:
        query = query.filter(ExportAp.id_ap == parameters["id_ap"])

    if "id_zp" in parameters:
        query = query.filter(ExportAp.id_zp == parameters["id_zp"])

    if "id_organism" in parameters:
        query = (
            query
            .join(Organisme, Organisme.nom_organisme == ExportAp.organisme)
            .filter(Organisme.id_organisme == parameters["id_organism"])
        )

    if "id_area" in parameters:
        query = (
            query
            .join(cor_zp_area, cor_zp_area.c.id_zp == ExportAp.id_zp)
            .filter(cor_zp_area.c.id_area == parameters["id_area"])
        )

    if "year" in parameters:
        query = query.filter(func.date_part("year", ExportAp.date_min) == parameters["year"])

    if "cd_nom" in parameters:
        query = (
            query
            .join(Taxref, Taxref.nom_valide == ExportAp.taxon)
            .filter(Taxref.cd_nom == parameters["cd_nom"])
        )

    data = query.all()

    if export_format == "csv":
        ap_list = []
        for d in data:
            ap = d.as_dict()
            ap_list.append(ap)
        return to_csv_resp(file_name, ap_list, ap_list[0].keys(), ";")
    else:
        features = []
        for d in data:
            feature = d.get_geofeature()
            features.append(feature)
        result = FeatureCollection(features)
        return to_json_resp(result, as_file=True, filename=file_name, indent=4)


@blueprint.route("/area-contain", methods=["POST"])
@json_resp
def check_presence_area_in_prospect_zone():
    data = request.get_json()

    ["geom_a", "geom_b"]
    try:
        assert "geom_a" in data
        assert "geom_b" in data
    except AssertionError:
        return {"message": "Missing geom_a or geom_b in posted JSON."}, 400

    query = db.session.execute(select([
            func.st_contains(
               func.ST_GeomFromGeoJSON(json.dumps(data["geom_a"])),
                func.ST_GeomFromGeoJSON(json.dumps(data["geom_b"])),
            )]
        )
    )
    return query.scalar()
