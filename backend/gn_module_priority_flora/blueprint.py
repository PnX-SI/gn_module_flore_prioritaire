import json
from datetime import datetime, date
from operator import or_

from flask import Blueprint, request, g
from sqlalchemy import Date
from sqlalchemy.dialects.postgresql import INTERVAL
from sqlalchemy.sql.functions import concat
from sqlalchemy.sql.expression import func, select
from utils_flask_sqla.response import json_resp, to_json_resp, to_csv_resp
from werkzeug.exceptions import BadRequest, Forbidden, InternalServerError, NotFound
from geoalchemy2.shape import from_shape, to_shape
from geojson import FeatureCollection
from shapely.geometry import shape

from geonature.core.gn_meta.models import TDatasets
from geonature.core.gn_permissions import decorators as permissions
from geonature.core.gn_permissions.tools import get_scopes_by_action
from geonature.utils.config import config
from ref_geo.models import LAreas, BibAreasTypes
from apptax.taxonomie.models import Taxref
from geonature.utils.env import db
from pypnnomenclature.models import TNomenclatures
from pypnusershub.db.models import User
from pypnusershub.db.models import Organisme
from gn_conservation_backend_shared.webservices.io import prepare_output

from gn_module_priority_flora import MODULE_CODE
from .models import (
    TZprospect,
    TApresence,
    ExportAp,
    cor_zp_observer,
    cor_zp_area,
    CorApArea,
)
from .repositories import translate_exported_columns, get_export_headers, StatRepository


blueprint = Blueprint("priority_flora", __name__)


@blueprint.route("/prospect-zones", methods=["GET"])
@permissions.check_cruved_scope("R", get_scope=True, module_code=MODULE_CODE)
@json_resp
def get_prospect_zones(scope):
    """
    Retourne toutes les zones de prospection du module.
    """
    parameters = request.args
    page = int(parameters.get("page", 0))
    limit = int(parameters.get("limit", 100))

    # TO CHECK : if 0 -> Forbidden déjà levée ?
    if scope == 0:
        raise Forbidden("Vous n'avez pas les droits permettant de consulter cette ZP.")

    # TODO: use a dedicated web service for transfert this user cruved (?)
    user_scopes = get_scopes_by_action(
        id_role=g.current_user.id_role, module_code=MODULE_CODE
    )

    # Build query
    query = select(TZprospect)
    if scope == 2:
        query = query.where(
            TZprospect.observers.any(
                or_(
                    User.id_role == g.current_user.id_role,
                    User.id_organisme == g.current_user.id_organisme,
                )
            )
        )
    if scope == 1:
        query = query.where(
            TZprospect.observers.any(
                User.id_role == g.current_user.id_role,
            )
        )

    if "id_zp" in parameters:
        query = query.where(TZprospect.id_zp == parameters["id_zp"])

    if "cd_nom" in parameters:
        query = query.where(TZprospect.taxonomy.has(cd_nom=parameters["cd_nom"]))

    if "id_area" in parameters:
        query = query.where(TZprospect.areas.any(id_area=parameters["id_area"]))

    if "id_organism" in parameters:
        query = query.where(
            TZprospect.observers.any(id_organisme=parameters["id_organism"])
        )

    if "year" in parameters:
        query = query.where(
            func.date_part("year", TZprospect.date_min) == parameters["year"]
        )

    filtered_number = db.session.scalar(select(func.count("*")).select_from(query))
    data = db.session.scalars(query.order_by(TZprospect.date_min.desc()).limit(limit).offset(page * limit)).unique().all()

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
        feature["properties"]["rights"] = d.get_instance_perms(user_scopes)
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

    query = select(TApresence)

    if "id_zp" in parameters:
        query = query.where(TApresence.id_zp == parameters["id_zp"])

    data = (
        db.session.scalars(
            query.order_by(TApresence.meta_create_date.desc())
            .limit(limit)
            .offset(page * limit)
        )
        .unique()
        .all()
    )

    features = []
    for d in data:
        feature = d.get_geofeature()
        features.append(feature)
    return FeatureCollection(features)


def edit_prospect_zone(scope, id_zp=None):
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
    new_shape = None
    if "geom_4326" in data:
        new_shape = shape(data.pop("geom_4326"))

    observers = None
    if "observers" in data:
        observers = data.pop("observers")
        observers = db.session.scalars(select(User).where(User.id_role.in_(observers))).all()

    if "initial_insert" not in data:
        data["initial_insert"] = "web"

    if "date_max" not in data and "date_min" in data:
        data["date_max"] = data["date_min"]

    if "id_dataset" not in data or data["id_dataset"] == "":
        raise BadRequest(f"Missing id_dataset")

    # Create prospect zone object
    if id_zp is not None:
        zp = db.session.get(TZprospect, id_zp)
    else:
        zp = TZprospect(**data)

    if new_shape is not None:
        zp.geom_4326 = from_shape(new_shape, srid=4326)

    if observers is not None:
        for o in observers:
            zp.observers.append(o)

    # Update or add prospect zone
    if zp:
        if not zp.has_instance_permission(scope):
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
@permissions.check_cruved_scope("C", get_scope=True, module_code=MODULE_CODE)
@json_resp
def add_prospect_zone(scope):
    return edit_prospect_zone(scope)


@blueprint.route("/prospect-zones/<int:id_zp>", methods=["PUT"])
@permissions.check_cruved_scope("U", get_scope=True, module_code=MODULE_CODE)
@json_resp
def update_prospect_zone(scope, id_zp):
    return edit_prospect_zone(scope, id_zp)


def edit_presence_area(scope, id_ap=None):
    """
    Édition d'une nouvelle aire de présence (ajout ou mise à jour).
    """
    data = dict(request.get_json())

    if id_ap is not None:
        data["id_ap"] = id_ap
    if data["id_ap"] is None:
        data.pop("id_ap")

    # TODO: if no geom 4326 with POST send 400 BAD REQUEST
    new_shape = None
    if "geom_4326" in data:
        new_shape = shape(data.pop("geom_4326"))

    perturbations = None
    if "perturbations" in data:
        perturbations = data.pop("perturbations")

    physiognomies = None
    if "physiognomies" in data:
        physiognomies = data.pop("physiognomies")

    if id_ap is not None:
        ap = db.session.get(TApresence, id_ap)
    else:
        ap = TApresence(**data)

    if new_shape is not None:
        ap.geom_4326 = from_shape(new_shape, srid=4326)

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
        zp = db.session.get(TZprospect, data["id_zp"])
        if not zp.has_instance_permission(scope):
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
@permissions.check_cruved_scope("C", get_scope=True, module_code=MODULE_CODE)
@json_resp
def add_presence_area(scope):
    return edit_presence_area(scope)


@blueprint.route("/presence-areas/<int:id_ap>", methods=["PUT"])
@permissions.check_cruved_scope("U", get_scope=True, module_code=MODULE_CODE)
@json_resp
def update_presence_area(scope, id_ap):
    return edit_presence_area(scope, id_ap)


@blueprint.route("/organisms", methods=["GET"])
@json_resp
@permissions.login_required
def get_organisms():
    """
    Retourne la liste de tous les organismes présents
    """
    data = (
        db.session.execute(
            select(
                Organisme.nom_organisme, Organisme.id_organisme
        )
            .distinct()
            .join(User, Organisme.id_organisme == User.id_organisme)
            .join(cor_zp_observer, cor_zp_observer.c.id_role == User.id_role)
            .join(TZprospect, TZprospect.id_zp == cor_zp_observer.c.id_zp)
            .order_by(Organisme.nom_organisme)
        ).all()
    )
    if data:
        return [{"name": org[0], "id_organism": org[1]} for org in data]
    return []


@blueprint.route("/municipalities", methods=["GET"])
@json_resp
def get_municipalities():
    """
    Retourne toutes les communes présentes dans le module
    """
    data = (
        db.session.execute(
            select(LAreas.area_name, LAreas.id_area)
                .distinct()
                .join(CorApArea, CorApArea.id_area == LAreas.id_area)
                .join(BibAreasTypes, BibAreasTypes.id_type == LAreas.id_type)
                .filter(BibAreasTypes.type_code == "COM")
                .order_by(LAreas.area_name)
        ).all()
    )

    if data:
        return [{"municipality": d[0], "id_area": d[1]} for d in data]
    return []


@blueprint.route("/prospect-zones/<int:id_zp>", methods=["GET"])
@permissions.check_cruved_scope("R", module_code=MODULE_CODE)
@json_resp
def get_prospect_zone(id_zp):
    zp = db.session.get_or_404(TZprospect, id_zp)
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
        "zp": zp.get_geofeature(
            fields=["observers", "taxonomy", "areas", "areas.area_type"]
        ),
    }


@blueprint.route("/presence-areas/<int:id_ap>", methods=["GET"])
@permissions.check_cruved_scope("R", module_code=MODULE_CODE)
@json_resp
def get_presence_area(id_ap):
    ap = db.get_or_404(TApresence, id_ap)
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


@blueprint.route("/prospect-zones/<int:id_zp>", methods=["DELETE"])
@permissions.check_cruved_scope("D", module_code=MODULE_CODE)
@json_resp
def delete_prospect_zone(id_zp):
    zp = db.get_or_404(TZprospect, id_zp)
    db.session.delete(zp)
    db.session.commit()
    return None, 204


@blueprint.route("/presence-areas/<int:id_ap>", methods=["DELETE"])
@permissions.check_cruved_scope("D", module_code=MODULE_CODE)
@json_resp
def delete_presence_area(id_ap):
    ap = db.get_or_404(TApresence, id_ap)
    db.session.delete(ap)
    db.session.commit()
    return None, 204


@blueprint.route("/presence-areas/export", methods=["GET"])
@permissions.check_cruved_scope("E", module_code=MODULE_CODE)
def export_presence_areas():
    """
    Télécharge les données d'une aire de présence
    """
    parameters = request.args

    export_format = (
        parameters["export_format"] if "export_format" in request.args else "geojson"
    )

    # Build query and get data from db
    query = select(ExportAp)

    if "id_ap" in parameters:
        query = query.where(ExportAp.id_ap == parameters["id_ap"])

    if "id_zp" in parameters:
        query = query.where(ExportAp.id_zp == parameters["id_zp"])

    if "id_organism" in parameters:
        query = query.join(TZprospect, TZprospect.id_zp == ExportAp.id_zp).where(
            TZprospect.observers.any(id_organisme=parameters["id_organism"])
        )

    if "id_area" in parameters:
        query = query.join(cor_zp_area, cor_zp_area.c.id_zp == ExportAp.id_zp).where(
            cor_zp_area.c.id_area == parameters["id_area"]
        )

    if "year" in parameters:
        query = query.where(
            func.date_part("year", ExportAp.date_min) == parameters["year"]
        )

    if "cd_nom" in parameters:
        query = query.join(Taxref, Taxref.cd_nom == ExportAp.sciname_code).where(
            Taxref.cd_nom == parameters["cd_nom"]
        )

    data = db.session.scalars(query).unique().all()

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
                    "properties": translate_exported_columns(
                        {
                            "id_zp": ap["id_zp"],
                            "sciname": ap["sciname"],
                            "sciname_code": ap["sciname_code"],
                            "date_min": ap["date_min"],
                            "date_max": ap["date_max"],
                            "observaters": ap["observaters"],
                        }
                    ),
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
    file_name = datetime.now().strftime("%Y_%m_%d_%Hh%Mm%S")
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
        return to_json_resp(
            result, as_file=True, filename=file_name, indent=4, extension="geojson"
        )


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
@permissions.check_cruved_scope("R", module_code="PRIORITY_FLORA")
@json_resp
def get_stats():

    # Get request parameters
    cd_nom = request.args.get("taxon-code")
    area_code = request.args.get("area-code")
    area_type = request.args.get("area-type")
    date_start = request.args.get("date-start", date.today())
    years = request.args.get("years-nbr", 5)

    statrepo = StatRepository(
        cd_nom=cd_nom,
        area_code=area_code,
        area_type=area_type,
        date_start=date_start,
        years=years,
    )

    data = {
        "prospections": statrepo.get_prospections(),
        "populations": statrepo.get_populations(),
        "habitats": statrepo.get_habitats(),
        "calculations": statrepo.get_calculations(),
    }

    return prepare_output(data)
