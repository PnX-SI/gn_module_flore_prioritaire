from geonature.core.gn_meta.models import TDatasets
from geonature.core.gn_permissions import decorators as permissions
from geonature.core.gn_permissions.tools import cruved_scope_for_user_in_module
from geonature.core.ref_geo.models import LAreas, BibAreasTypes
from geonature.core.taxonomie.models import Taxref
from geonature.utils.env import db

from datetime import datetime, date
import json
from operator import or_
from flask import Blueprint, request
from geoalchemy2.shape import from_shape, to_shape
from geojson import FeatureCollection
from shapely.geometry import asShape
from sqlalchemy import Date
from sqlalchemy.dialects.postgresql import INTERVAL
from sqlalchemy.sql.functions import concat
from sqlalchemy.sql.expression import func, select
from werkzeug.exceptions import BadRequest, Forbidden, InternalServerError, NotFound
from pypnnomenclature.models import TNomenclatures
from pypnusershub.db.models import User
from pypnusershub.db.models import Organisme
from utils_flask_sqla.response import json_resp, to_json_resp, to_csv_resp

from gn_module_priority_flora import MODULE_CODE, METADATA_CODE
from .models import (
    TZprospect,
    TApresence,
    ExportAp,
    cor_zp_observer,
    CorApArea,
)
from .repositories import translate_exported_columns, get_export_headers, StatRepository


blueprint = Blueprint("priority_flora", __name__)


@blueprint.route("/prospect-zones", methods=["GET"])
@permissions.check_cruved_scope("R", get_role=True, module_code=MODULE_CODE)
@json_resp
def get_prospect_zones(info_role):
    """
    Retourne toutes les zones de prospection du module.
    """
    parameters = request.args
    page = int(parameters.get("page", 0))
    limit = int(parameters.get("limit", 100))

    if info_role.value_filter == "0":
        raise Forbidden("Vous n'avez pas les droits permettant de consulter cette ZP.")

    # TODO: use a dedicated web service for transfert this user cruved (?)
    user_cruved = cruved_scope_for_user_in_module(
        id_role=info_role.id_role, module_code=MODULE_CODE
    )
    info_role.id_organism = (
        db.session.query(User.id_organisme).filter(User.id_role == info_role.id_role).scalar()
    )

    # Build query
    query = TZprospect.query
    if info_role.value_filter == "2":
        query = query.filter(
            TZprospect.observers.any(
                or_(
                    User.id_role == info_role.id_role,
                    User.id_organisme == info_role.id_organisme,
                )
            )
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
                "cd_nom",
                "taxonomy.nom_valide",
                "date_min",
                "date_max",
                "observers",
                "observers.organisme",
                "areas.area_name",
                "area",
                "ap.id_ap",
            ],
        )
        cruved_auth = d.get_model_cruved(info_role, user_cruved[0])
        feature["properties"]["rights"] = cruved_auth
        feature["properties"]["organisms_list"] = ", ".join(
            list(
                set(
                    map(
                        lambda obs: obs["organisme"]["nom_organisme"],
                        feature["properties"]["observers"],
                    )
                )
            )
        )
        feature["properties"]["ap_number"] = len(feature["properties"]["ap"])
        features.append(feature)
    return {"total": filtered_number, "items": FeatureCollection(features)}


@blueprint.route("/presence-areas", methods=["GET"])
@permissions.check_cruved_scope("R", module_code=MODULE_CODE)
@json_resp
def get_presence_areas():
    """
    Retourne toutes les aires de présence d'une zone de prospection.
    """
    parameters = request.args
    page = int(parameters.get("page", 0))
    limit = int(parameters.get("limit", 100))

    query = db.session.query(TApresence)

    if "id_zp" in parameters:
        query = query.filter(TApresence.id_zp == parameters["id_zp"])

    data = (
        query.order_by(TApresence.meta_create_date.desc()).limit(limit).offset(page * limit).all()
    )

    features = []
    for d in data:
        feature = d.get_geofeature()
        features.append(feature)
    return FeatureCollection(features)


def edit_prospect_zone(info_role, id_zp=None):
    """
    Poste une nouvelle zone de prospection
    """
    data = dict(request.get_json())

    # Prepare data
    if id_zp is not None:
        data["id_zp"] = id_zp
    if data["id_zp"] is None:
        data.pop("id_zp")

    # TODO: if no geom 4326 with POST send 400 BAD REQUEST
    shape = None
    if "geom_4326" in data:
        shape = asShape(data.pop("geom_4326"))

    observers = None
    if "observers" in data:
        observers = data.pop("observers")
        observers = db.session.query(User).filter(User.id_role.in_(observers)).all()

    if "initial_insert" not in data:
        data["initial_insert"] = "web"

    if "date_max" not in data and "date_min" in data:
        data["date_max"] = data["date_min"]

    if "id_dataset" not in data or data["id_dataset"] == "":
        dataset_code = METADATA_CODE
        Dataset = (
            db.session.query(TDatasets).filter(TDatasets.dataset_shortname == dataset_code).first()
        )
        if Dataset:
            data["id_dataset"] = Dataset.id_dataset
        else:
            raise BadRequest(f"Module dataset shortname '{dataset_code}' was not found !")

    # Create prospect zone object
    if id_zp is not None:
        zp = db.session.query(TZprospect).filter_by(id_zp=id_zp).first()
    else:
        zp = TZprospect(**data)

    if shape is not None:
        zp.geom_4326 = from_shape(shape, srid=4326)

    if observers is not None:
        for o in observers:
            zp.observers.append(o)

    # Update or add prospect zone
    if "id_zp" in data:
        if info_role.value_filter in ("0", "1", "2"):
            if info_role.value_filter == "0":
                check_cruved = False
            else:
                query = db.session.query(TZprospect).filter_by(id_zp=data["id_zp"])
                if info_role.value_filter == "2":
                    query = query.filter(
                        TZprospect.observers.any(
                            or_(
                                User.id_role == info_role.id_role,
                                User.id_organisme == info_role.id_organisme,
                            )
                        )
                    )
                if info_role.value_filter == "1":
                    query = query.filter(
                        TZprospect.observers.any(
                            User.id_role == info_role.id_role,
                        )
                    )
                check_cruved = db.session.query(query.exists()).scalar()

            if not check_cruved:
                raise Forbidden("Vous n'avez pas les droits pour éditer cette ZP.")

        for key, value in data.items():
            if hasattr(zp, key):
                setattr(zp, key, value)

        db.session.merge(zp)
    else:
        db.session.add(zp)

    db.session.commit()
    db.session.flush()

    return zp.get_geofeature(fields=["observers"])


@blueprint.route("/prospect-zones", methods=["POST"])
@permissions.check_cruved_scope("C", get_role=True, module_code=MODULE_CODE)
@json_resp
def add_prospect_zone(info_role):
    return edit_prospect_zone(info_role)


@blueprint.route("/prospect-zones/<int:id_zp>", methods=["PUT"])
@permissions.check_cruved_scope("U", get_role=True, module_code=MODULE_CODE)
@json_resp
def update_prospect_zone(info_role, id_zp):
    return edit_prospect_zone(info_role, id_zp)


def edit_presence_area(info_role, id_ap=None):
    """
    Édition d'une nouvelle aire de présence (ajout ou mise à jour).
    """
    data = dict(request.get_json())

    if id_ap is not None:
        data["id_ap"] = id_ap
    if data["id_ap"] is None:
        data.pop("id_ap")

    # TODO: if no geom 4326 with POST send 400 BAD REQUEST
    shape = None
    if "geom_4326" in data:
        shape = asShape(data.pop("geom_4326"))

    perturbations = None
    if "perturbations" in data:
        perturbations = data.pop("perturbations")

    physiognomies = None
    if "physiognomies" in data:
        physiognomies = data.pop("physiognomies")

    if id_ap is not None:
        ap = db.session.query(TApresence).filter_by(id_ap=id_ap).first()
    else:
        ap = TApresence(**data)

    if shape is not None:
        ap.geom_4326 = from_shape(shape, srid=4326)

    if perturbations is not None:
        ap_pertubations = (
            db.session.query(TNomenclatures)
            .filter(
                TNomenclatures.id_nomenclature.in_(
                    [pert["id_nomenclature"] for pert in perturbations]
                )
            )
            .all()
        )
        for item in ap_pertubations:
            ap.perturbations.append(item)

    if physiognomies is not None:
        ap_physiognomies = (
            db.session.query(TNomenclatures)
            .filter(
                TNomenclatures.id_nomenclature.in_(
                    [pĥysio["id_nomenclature"] for pĥysio in physiognomies]
                )
            )
            .all()
        )
        for item in ap_physiognomies:
            ap.physiognomies.append(item)

    if "id_ap" in data:
        if info_role.value_filter in ("0", "1", "2"):
            if info_role.value_filter == "0":
                check_cruved = False
            else:
                query = db.session.query(TZprospect).filter_by(id_zp=data["id_zp"])
                if info_role.value_filter == "2":
                    query = query.filter(
                        TZprospect.observers.any(
                            or_(
                                User.id_role == info_role.id_role,
                                User.id_organisme == info_role.id_organisme,
                            )
                        )
                    )
                elif info_role.value_filter == "1":
                    query = query.filter(
                        TZprospect.observers.any(
                            User.id_role == info_role.id_role,
                        )
                    )
                check_cruved = db.session.query(query.exists()).scalar()

            if not check_cruved:
                raise Forbidden("Vous n'avez pas les droits pour éditer cette AP.")

        for key, value in data.items():
            if hasattr(ap, key):
                setattr(ap, key, value)

        db.session.merge(ap)
    else:
        db.session.add(ap)

    db.session.commit()
    db.session.flush()

    return ap.get_geofeature()


@blueprint.route("/presence-areas", methods=["POST"])
@permissions.check_cruved_scope("C", get_role=True, module_code=MODULE_CODE)
@json_resp
def add_presence_area(info_role):
    return edit_presence_area(info_role)


@blueprint.route("/presence-areas/<int:id_ap>", methods=["PUT"])
@permissions.check_cruved_scope("U", get_role=True, module_code=MODULE_CODE)
@json_resp
def update_presence_area(info_role, id_ap):
    return edit_presence_area(info_role, id_ap)


@blueprint.route("/organisms", methods=["GET"])
@json_resp
def get_organisms():
    """
    Retourne la liste de tous les organismes présents
    """
    query = (
        db.session.query(Organisme.nom_organisme, Organisme.id_organisme)
        .distinct()
        .join(User, Organisme.id_organisme == User.id_organisme)
        .join(cor_zp_observer, cor_zp_observer.c.id_role == User.id_role)
        .join(TZprospect, TZprospect.id_zp == cor_zp_observer.c.id_zp)
        .order_by(Organisme.nom_organisme)
    )
    data = query.all()

    if data:
        return [{"name": org[0], "id_organism": org[1]} for org in data]
    raise NotFound("No organisms found !")


@blueprint.route("/municipalities", methods=["GET"])
@json_resp
def get_municipalities():
    """
    Retourne toutes les communes présentes dans le module
    """
    query = (
        db.session.query(LAreas.area_name, LAreas.id_area)
        .distinct()
        .join(CorApArea, CorApArea.id_area == LAreas.id_area)
        .join(BibAreasTypes, BibAreasTypes.id_type == LAreas.id_type)
        .filter(BibAreasTypes.type_code == "COM")
        .order_by(LAreas.area_name)
    )
    data = query.all()

    if data:
        return [{"municipality": d[0], "id_area": d[1]} for d in data]
    raise InternalServerError("An error occured !")


@blueprint.route("/prospect-zones/<int:id_zp>", methods=["GET"])
@permissions.check_cruved_scope("R", module_code=MODULE_CODE)
@json_resp
def get_prospect_zone(id_zp):
    zp = db.session.query(TZprospect).get(id_zp)
    if zp:
        return {
            "aps": FeatureCollection(
                [
                    ap.get_geofeature(
                        fields=[
                            "incline",
                            "habitat",
                            "threat_level",
                            "pheno",
                            "frequency_method",
                            "counting",
                            "perturbations",
                            "physiognomies",
                        ]
                    )
                    for ap in zp.ap
                ]
            ),
            "zp": zp.get_geofeature(fields=["observers", "taxonomy", "areas", "areas.area_type"]),
        }
    raise NotFound(f"Prospect zone with ID {id_zp} not found !")


@blueprint.route("/presence-areas/<int:id_ap>", methods=["GET"])
@permissions.check_cruved_scope("R", module_code=MODULE_CODE)
@json_resp
def get_presence_area(id_ap):
    ap = db.session.query(TApresence).get(id_ap)
    if ap:
        return ap.get_geofeature(
            fields=[
                "incline",
                "habitat",
                "threat_level",
                "pheno",
                "frequency_method",
                "counting",
                "perturbations",
                "physiognomies",
            ]
        )
    raise NotFound(f"Presence area with ID {id_ap} not found !")


@blueprint.route("/prospect-zones/<int:id_zp>", methods=["DELETE"])
@permissions.check_cruved_scope("D", module_code=MODULE_CODE)
@json_resp
def delete_prospect_zone(id_zp):
    zp = db.session.query(TZprospect).get(id_zp)
    if zp:
        db.session.delete(zp)
        db.session.commit()
        return None, 204
    raise NotFound(f"Prospect zone with ID {id_zp} not found !")


@blueprint.route("/presence-areas/<int:id_ap>", methods=["DELETE"])
@permissions.check_cruved_scope("D", module_code=MODULE_CODE)
@json_resp
def delete_presence_area(id_ap):
    ap = db.session.query(TApresence).get(id_ap)
    if ap:
        db.session.delete(ap)
        db.session.commit()
        return None, 204
    raise NotFound(f"Presence area with ID {id_ap} not found !")


@blueprint.route("/presence-areas/export", methods=["GET"])
@permissions.check_cruved_scope("E", module_code=MODULE_CODE)
def export_presence_areas():
    """
    Télécharge les données d'une aire de présence
    """
    parameters = request.args

    export_format = parameters["export_format"] if "export_format" in request.args else "geojson"

    # Build query and get data from db
    query = db.session.query(ExportAp)

    if "id_ap" in parameters:
        query = query.filter(ExportAp.id_ap == parameters["id_ap"])

    if "id_zp" in parameters:
        query = query.filter(ExportAp.id_zp == parameters["id_zp"])

    if "id_organism" in parameters:
        query = query.join(TZprospect, TZprospect.id_zp == ExportAp.id_zp).filter(
            TZprospect.observers.any(id_organisme=parameters["id_organism"])
        )

    if "id_area" in parameters:
        query = query.join(cor_zp_area, cor_zp_area.c.id_zp == ExportAp.id_zp).filter(
            cor_zp_area.c.id_area == parameters["id_area"]
        )

    if "year" in parameters:
        query = query.filter(func.date_part("year", ExportAp.date_min) == parameters["year"])

    if "cd_nom" in parameters:
        query = query.join(Taxref, Taxref.cd_nom == ExportAp.sciname_code).filter(
            Taxref.cd_nom == parameters["cd_nom"]
        )

    data = query.all()

    # Format data
    output_items = []
    computed_zp = []
    for d in data:
        ap = d.as_dict()

        prepared_ap = {}
        if export_format == "csv":
            # Add geom column remove previously by .as_dict() method.
            ap["zp_geom_local"] = to_shape(d.zp_geom_local)
            ap["ap_geom_local"] = to_shape(d.ap_geom_local)
            prepared_ap = translate_exported_columns(ap)
        elif export_format == "geojson":
            if ap["id_zp"] not in computed_zp:
                computed_zp.append(ap["id_zp"])
                prepared_zp = {
                    "geometry": ap["zp_geojson"],
                    "properties": translate_exported_columns({
                        "id_zp": ap["id_zp"],
                        "sciname": ap["sciname"],
                        "sciname_code": ap["sciname_code"],
                        "date_min": ap["date_min"],
                        "date_max": ap["date_max"],
                        "observaters": ap["observaters"],
                    })
                }
                output_items.append(prepared_zp)

            prepared_ap["geometry"] = ap["ap_geojson"]
            geom_fields = [
                "zp_ap_geojson",
                "zp_geojson",
                "zp_geom_local",
                "ap_geojson",
                "ap_geom_local",
            ]
            for field in geom_fields:
                ap.pop(field, None)
            prepared_ap["properties"] = translate_exported_columns(ap)

        output_items.append(prepared_ap)

    # Return data
    file_name = datetime.datetime.now().strftime("%Y_%m_%d_%Hh%Mm%S")
    if export_format == "csv":
        headers = get_export_headers()
        return to_csv_resp(file_name, output_items, headers, ";")
    else:
        features = []
        for ap in output_items:
            feature = {
                "type": "Feature",
                "geometry": json.loads(ap["geometry"]),
                "properties": ap["properties"],
            }
            features.append(feature)
        result = FeatureCollection(features)
        return to_json_resp(result, as_file=True, filename=file_name, indent=4, extension="geojson")


@blueprint.route("/area-contain", methods=["POST"])
@json_resp
def check_geom_a_contain_geom_b():
    data = request.get_json()

    ["geom_a", "geom_b"]
    try:
        assert "geom_a" in data
        assert "geom_b" in data
    except AssertionError:
        raise BadRequest("Missing geom_a or geom_b in posted JSON.")

    query = db.session.execute(
        select(
            [
                func.st_contains(
                    func.ST_GeomFromGeoJSON(json.dumps(data["geom_a"])),
                    func.ST_GeomFromGeoJSON(json.dumps(data["geom_b"])),
                )
            ]
        )
    )
    return query.scalar()


@blueprint.route("/stats", methods=["GET"])
@permissions.check_cruved_scope("R", module_code="CONSERVATION_STRATEGY")
@json_resp
def get_stats():

    # Get request parameters
    cd_nom = request.args.get("taxon-code")
    area_code = request.args.get("area-code")
    area_type_code = request.args.get("area-type")
    date_start = request.args.get("date-start", date.today())
    years = request.args.get("nbr", 5)

    statrepo = StatRepository(cd_nom=cd_nom, area_code=area_code, area_type_code=area_type_code, date_start=date_start, years=years)

    data = {
        "prospections": statrepo.get_prospections(),
        "populations" : statrepo.get_populations(),
        "habitats" : statrepo.get_habitats()
        }

    return data
