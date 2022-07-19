import datetime
import json
from logging import info
from operator import or_

from flask import Blueprint, request, send_from_directory, jsonify
from geojson.feature import Feature
from geonature.core.gn_permissions.tools import cruved_scope_for_user_in_module, get_or_fetch_user_cruved

from shapely.geometry import asShape
from geoalchemy2.shape import from_shape, to_shape
from geojson import FeatureCollection
from sqlalchemy.sql.expression import func, select
from sqlalchemy.sql.functions import user
from werkzeug.exceptions import BadRequest, Forbidden

from geonature.utils.env import DB, ROOT_DIR
from utils_flask_sqla_geo.utilsgeometry import export_geodata_as_file
from geonature.utils.env import DB

from utils_flask_sqla.response import json_resp, to_json_resp, to_csv_resp
from pypnnomenclature.models import TNomenclatures
from pypnusershub.db.models import User
from .models import (
    TZprospect,
    TApresence,
    ExportAp,
    cor_zp_area
)
from geonature.core.taxonomie.models import Taxref
from geonature.core.gn_permissions import decorators as permissions
from pypnusershub.db.models import Organisme

blueprint = Blueprint("priority_flora", __name__)


@blueprint.route("/z_prospects", methods=["GET"])
@permissions.check_cruved_scope("R", True, module_code="priority_flora")
@json_resp
def get_zprospect(info_role):
    """
    Retourne toutes les zones de prospection du module
    """
    parameters = request.args
    page = int(parameters.get("page", 0))
    limit = int(parameters.get("limit", 100))
    user_cruved = cruved_scope_for_user_in_module(
        id_role=info_role.id_role, module_code="priority_flora"
    )
    q = TZprospect.query
    if info_role.value_filter == "2":
        q = q.filter(
                TZprospect.observers.any(or_(
                    User.id_role == info_role.id_role,
                    User.id_organisme == info_role.id_organisme,
                ))
        )
    if info_role.value_filter == "1":
        q = q.filter(
                TZprospect.observers.any(
                    User.id_role == info_role.id_role,
                )
        )
    if "indexzp" in parameters:
        q = q.filter(TZprospect.indexzp == parameters["indexzp"])

    if "cd_nom" in parameters:
        q = q.filter(TZprospect.taxonomy.has(cd_nom=parameters["cd_nom"]))

    if "id_area" in parameters:
        q = q.filter(TZprospect.areas.any(id_area=parameters["id_area"]))

    if "id_organism" in parameters:
        q = q.filter(TZprospect.observers.any(id_organisme=parameters["id_organism"]))

    if "year" in parameters:
        q = q.filter(func.date_part("year", TZprospect.date_min) == parameters["year"])
    filtered_number = q.count()
    data = q.order_by(TZprospect.date_min.desc()).limit(limit).offset(page * limit)
    features = []
    for d in data:
        feature = d.get_geofeature(
            fields=[
                "indexzp",
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
        feature["properties"]["organisms_list"] = ",".join(
            map(
                lambda obs: obs["organisme"]["nom_organisme"],
                feature["properties"]["observers"],
            )
        )
        features.append(feature)
    return {"total": filtered_number, "items": FeatureCollection(features)}


@blueprint.route("/apresences", methods=["GET"])
@permissions.check_cruved_scope("R", module_code="priority_flora")
@json_resp
def get_apresences():
    """
    Retourne toutes les aires de présence d'une zone de prospection
    """
    parameters = request.args
    q = TApresence.query

    if "indexzp" in parameters:
        q = q.filter(TApresence.indexzp == parameters["indexzp"])
    data = q.all()
    features = []

    for d in data:
        feature = d[0].get_geofeature()
        features.append(feature)

    return FeatureCollection(features)


@blueprint.route("/post_zp", methods=["POST"])
@blueprint.route("/post_zp/<int:id_zp>", methods=["POST"])
@permissions.check_cruved_scope("C", True, module_code="priority_flora")
@json_resp
def post_zp(info_role, id_zp=None):
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
    zp = TZprospect(**data)
    zp.geom_4326 = from_shape(shape, srid=4326)

    observers = DB.session.query(User).filter(User.id_role.in_(tab_observer)).all()

    for o in observers:
        zp.observers.append(o)
    if "indexzp" in data:
        if info_role.value_filter in ("1", "2"):
            q = DB.session.query(TZprospect).filter_by(indexzp=data["indexzp"])
            if info_role.value_filter == "2":
                q = q.filter(
                        TZprospect.observers.any(or_(
                            User.id_role == info_role.id_role,
                            User.id_organisme == info_role.id_organisme,
                        ))
                )
            if info_role.value_filter == "1":
                q = q.filter(
                        TZprospect.observers.any(
                            User.id_role == info_role.id_role,
                        )
                )
            check_cruved = DB.session.query(q.exists()).scalar()
            if not check_cruved:
                raise Forbidden("Vous n'avez pas les droits pour éditer cette ZP")
        
        DB.session.merge(zp)
    else:
        DB.session.add(zp)
    DB.session.commit()

    return zp.as_geofeature("geom_4326", "indexzp", fields=["observers"])


@blueprint.route("/post_ap", methods=["POST"])
@permissions.check_cruved_scope("C", True, module_code="priority_flora")
@json_resp
def post_ap(info_role):
    """
    Poste une nouvelle aire de présence
    """
    data = dict(request.get_json())
    tab_pertu = []
    if data["indexap"] is None:
        data.pop("indexap")

    if "cor_ap_perturbation" in data:
        tab_pertu = data.pop("cor_ap_perturbation")

    # TODO if no geom 4326 : 400
    shape = asShape(data.pop("geom_4326"))
    ap = TApresence(**data)
    ap.geom_4326 = from_shape(shape, srid=4326)
    if tab_pertu:
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

    if "indexap" in data:
        if info_role.value_filter in ("1", "2"):
            q = DB.session.query(TZprospect).filter_by(indexzp=data["indexzp"])
            if info_role.value_filter == "2":
                q = q.filter(
                        TZprospect.observers.any(or_(
                            User.id_role == info_role.id_role,
                            User.id_organisme == info_role.id_organisme,
                        ))
                )
            if info_role.value_filter == "1":
                q = q.filter(
                        TZprospect.observers.any(
                            User.id_role == info_role.id_role,
                        )
                )
            check_cruved = DB.session.query(q.exists()).scalar()
            if not check_cruved:
                raise Forbidden("Vous n'avez pas les droits pour éditer cette AP")
        
        DB.session.merge(ap)
    else:
        DB.session.add(ap)
    DB.session.commit()

    return ap.as_geofeature("geom_4326", "indexap", True)


@blueprint.route("/organismes", methods=["GET"])
def get_organisme():
    """
    Retourne la liste de tous les organismes présents
    """
    q = """
    SELECT DISTINCT b.nom_organisme, b.id_organisme
    FROM utilisateurs.bib_organismes b
    JOIN utilisateurs.t_roles r ON r.id_organisme = b.id_organisme
    JOIN pr_priority_flora.cor_zp_obs c ON c.id_role = r.id_role
    ORDER by b.nom_organisme ASC
    """

    data = DB.session.execute(q)
    if data:
        return jsonify([{"name": o[0], "id_organism": o[1]} for o in data])
    return None


@blueprint.route("/communes", methods=["GET"])
def get_commune():
    """
    Retourne toutes les communes présentes dans le module
    """
    q = """
    SELECT DISTINCT area_name, l.id_area
    FROM ref_geo.l_areas l
    JOIN pr_priority_flora.cor_ap_area ap ON ap.id_area = l.id_area
    JOIN ref_geo.bib_areas_types b ON b.id_type = l.id_type
    WHERE b.type_code = 'COM'
    ORDER BY area_name ASC
    """

    data = DB.session.execute(q)
    if data:
        return jsonify([{"municipality": c[0], "id_area": c[1]} for c in data])
    return None


@blueprint.route("/sites", methods=["GET"])
@permissions.check_cruved_scope("R", module_code="priority_flora")
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
@blueprint.route("/zp/<id_zp>", methods=["GET"])
@permissions.check_cruved_scope("R", module_code="priority_flora")
def get_one_zp(id_zp):
    print("ENTER LA ?????")
    zp = DB.session.query(TZprospect).get(id_zp)
    if zp:
        return jsonify({
            "aps": FeatureCollection([ap.get_geofeature() for ap in zp.ap]),
            "zp": zp.as_geofeature(
                "geom_4326",
                "indexzp",
                fields=["observers", "taxonomy", "areas", "areas.area_type"],
            ),
        })
    return None


@blueprint.route("/ap/<int:id_ap>", methods=["GET"])
@permissions.check_cruved_scope("R", module_code="priority_flora")
@json_resp
def get_one_ap(id_ap):
    
    ap = DB.session.query(TApresence).get(id_ap)

    return ap.get_geofeature()


#  route get One Zp
@blueprint.route("/zp/<int:id_zp>", methods=["DELETE"])
@permissions.check_cruved_scope("D", module_code="priority_flora")
@json_resp
def delete_one_zp(id_zp):

    zp = DB.session.query(TZprospect).get(id_zp)

    if zp:
        DB.session.delete(zp)
        DB.session.commit()
        return {"message": "delete with success"}, 200
    return None


@blueprint.route("/ap/<int:id_ap>", methods=["DELETE"])
@permissions.check_cruved_scope("D", module_code="priority_flora")
@json_resp
def delete_one_ap(id_ap):
    ap = DB.session.query(TApresence).get(id_ap)
    if ap:
        DB.session.delete(ap)
        DB.session.commit()
        return {"message": "delete with success"}, 200
    return None


@blueprint.route("/export_ap", methods=["GET"])
@permissions.check_cruved_scope("E", module_code="priority_flora")
def export_ap():
    """
    Télécharge les données d'une aire de présence
    """
    parameters = request.args

    export_format = (
        parameters["export_format"] if "export_format" in request.args else "shapefile"
    )

    file_name = datetime.datetime.now().strftime("%Y_%m_%d_%Hh%Mm%S")
    q = DB.session.query(ExportAp)

    if "indexap" in parameters:
        q = DB.session.query(ExportAp).filter(ExportAp.id_ap == parameters["indexap"])
    elif "indexzp" in parameters:
        q = DB.session.query(ExportAp).filter(
            ExportAp.id_zp == parameters["indexzp"]
        )
    elif "organisme" in parameters:
        q = DB.session.query(ExportAp).filter(
            ExportAp.organisme == parameters["organisme"]
        )
    elif "id_area" in parameters:
        q = DB.session.query(ExportAp).join(
            cor_zp_area, cor_zp_area.c.indexzp == ExportAp.id_zp
        ).filter(
            cor_zp_area.c.id_area == parameters["id_area"]
        )
    elif "year" in parameters:
        q = DB.session.query(ExportAp).filter(
            func.date_part("year", ExportAp.date_min) == parameters["year"]
        )
    elif "cd_nom" in parameters:
        q = DB.session.query(ExportAp).filter(ExportAp.cd_nom == parameters["cd_nom"])

    data = q.all()
    features = []

    if export_format == "csv":
        tab_ap = []

        for d in data:
            ap = d.as_dict()
            tab_ap.append(ap)

        return to_csv_resp(file_name, tab_ap, tab_ap[0].keys(), ";")

    else:
        db_cols = [
            db_col for db_col in ExportAp.__table__.columns
        ]
        dir_path = str(ROOT_DIR / "backend/static/shapefiles")
        export_geodata_as_file(
            view=ExportAp,
            srid=2154,
            db_cols=db_cols,
            data=data,
            dir_path=dir_path,
            file_name=file_name,
            geom_col="ap_geom_local",
            geojson_col=None,
            export_format="gpkg"
        )
        # FionaShapeService.create_shapes_struct(
        #     db_cols=ExportAp.__mapper__.c,
        #     srid=2154,
        #     dir_path=dir_path,
        #     file_name=file_name,
        # )

        # for row in data:
        #     FionaShapeService.create_feature(row.as_dict(), row.ap_geom_local)



        # FionaShapeService.save_and_zip_shapefiles()


        # db_cols = [
        #     db_col for db_col in ExportAp.__table__.columns
        # ]
        # dir_name, file_name = export_as_geo_file(
        #     export_format=export_format,
        #     export_view=ExportAp,
        #     db_cols=db_cols,
        #     geojson_col=None,
        #     data=data,
        #     file_name=file_name,
        # )
        # db_cols = [
        #     db_col for db_col in export_view.db_cols if db_col.key in export_columns
        # ]


        return send_from_directory(dir_path, file_name + ".zip", as_attachment=True)


@blueprint.route("/area_contain", methods=["POST"])
def check_ap_in_zp():

    data = request.get_json()

    ["geom_a", "geom_b"]
    try:
        assert "geom_a" in data
        assert "geom_b" in data
    except AssertionError:
        raise BadRequest("missing geom_a or geom_b in posted JSON")
    q = DB.session.execute(select([
            func.st_contains(
               func.ST_GeomFromGeoJSON(json.dumps(data["geom_a"])),
                func.ST_GeomFromGeoJSON(json.dumps(data["geom_b"])),
            )]
        )
    )
    result = q.scalar()
    return jsonify(result)
    