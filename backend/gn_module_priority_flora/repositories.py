from geonature.utils.env import DB
from geonature.core.ref_geo.models import LAreas

from sqlalchemy import func, select, case
from sqlalchemy.orm import aliased
from pypnusershub.db.models import User
from pypnnomenclature.models import TNomenclatures

from .models import (
    TApresence,
    TZprospect,
    cor_zp_observer,
    cor_zp_area,
    CorApArea,
    cor_ap_physiognomy,
    CorApPerturbation
)

def get_export_mapping_columns():
    # Use this dictionary to define export columns order.
    # Change value to redefine or translate the exported column name.
    # Remove item to remove column from the export.
    return {
       "id_zp": "id_zp",
       "sciname": "taxon",
       "sciname_code": "cd_nom",
       "date_min": "date_min",
       "date_max": "date_max",
       "observaters": "observateurs",
       "zp_surface": "zp_surface",
       "zp_geom_local": "zp_geom_local",
       "id_ap": "id_ap",
       "municipalities": "communes",
       "ap_surface": "ap_surface",
       "ap_geom_local": "ap_geom_local",
       "altitude_min": "altitude_min",
       "altitude_max": "altitude_max",
       "incline": "pente",
       "physiognomies": "physionomies",
       "habitat_state": "etat_dominant_habitat",
       "favorable_state_percentage": "pourcentage_statut_favorable",
       "threat_level": "menaces",
       "perturbations": "perturbations",
       "phenology": "phenologie",
       "frequency_method": "methode_frequence",
       "frequency": "frequence",
       "counting_method": "methode_comptage",
       "total_min" : "total_min",
       "total_max": "total_max",
       "comment": "remarque",
    }

def get_export_headers():
    return get_export_mapping_columns().values()

def translate_exported_columns(data):
    mapping_columns = get_export_mapping_columns()
    translated_sorted_data = dict(
        (column_name, data[field])
        for (field, column_name) in mapping_columns.items()
        if field in data
    )
    return translated_sorted_data

class StatRepository:
    def get_prospections():
        # Subqueries
        commune = (
            select([LAreas.id_area, LAreas.area_name])
            .where(LAreas.id_type == 25)
        ).cte("commune")

        departement = (
            select([LAreas.id_area, LAreas.area_name, LAreas.area_code])
            .where(LAreas.id_type == 26)
        ).cte("departement")


        observateur = (
            DB.session.query(
                cor_zp_observer.c.id_zp,
                func.string_agg(func.concat(User.nom_role, " ", User.prenom_role), ', ').label("observateur")
            ).join(User, User.id_role == cor_zp_observer.c.id_role)
            .group_by(cor_zp_observer.c.id_zp)
        ).cte("observateur")

        apresence = (
            DB.session.query(
                TZprospect.id_zp,
                func.count(TApresence.id_ap).label("nb_ap")
            ).outerjoin(TApresence, TApresence.id_zp == TZprospect.id_zp)
            .group_by(TZprospect.id_zp)
        ).cte("apresence")

        # Prepare column
        presence_ap = case(
            [(func.max(apresence.c.nb_ap) > 0,("Oui"))],
            else_=("Non")
        )

        # Execute query
        query = (
            DB.session.query(
                TZprospect.id_zp.label("id-zp"),
                TZprospect.date_min.label("date-min"),
                func.string_agg(commune.c.area_name, ', ').label("communes"),
                func.string_agg(departement.c.area_name, ', ').label("departement"),
                func.max(observateur.c.observateur).label("observateurs"),
                presence_ap.label("presence-ap"),
                TZprospect.cd_nom.label("cd-nom")
            )
            .outerjoin(cor_zp_area, cor_zp_area.c.id_zp == TZprospect.id_zp)
            .outerjoin(commune, commune.c.id_area == cor_zp_area.c.id_area)
            .outerjoin(departement, departement.c.id_area == cor_zp_area.c.id_area)
            .outerjoin(observateur, observateur.c.id_zp == TZprospect.id_zp)
            .outerjoin(apresence, apresence.c.id_zp == TZprospect.id_zp)
            .group_by(TZprospect.id_zp)
        )

        data = query.all()
        return [d._asdict() for d in data]

    def get_populations():
        # Subqueries
        commune = (
            select([LAreas.id_area, LAreas.area_name])
            .where(LAreas.id_type == 25)
        ).cte("commune")

        # Aliased tables
        TNomenclaturesF= aliased(TNomenclatures)
        TNomenclaturesC = aliased(TNomenclatures)

        # Execute query
        query = (
            DB.session.query(
                TApresence.id_ap.label("id-ap"),
                TApresence.id_zp.label("id-zp"),
                TApresence.area.label("surface-ap"),
                func.round(TApresence.frequency).label("frequence-occurence"),
                func.max((TApresence.total_min+TApresence.total_max)/2).label("effectifs"),
                func.string_agg(commune.c.area_name, ', ').label("communes"),
                func.max(TNomenclaturesF.label_default).label("methode-estimation"),
                func.max(TNomenclaturesC.label_default).label("type-comptage")
            )
            .outerjoin(CorApArea, CorApArea.id_ap == TApresence.id_ap)
            .outerjoin(commune, commune.c.id_area == CorApArea.id_area)
            .outerjoin(TNomenclaturesF, TNomenclaturesF.id_nomenclature == TApresence.id_nomenclature_frequency_method)
            .outerjoin(TNomenclaturesC, TNomenclaturesC.id_nomenclature == TApresence.id_nomenclature_counting)
            .group_by(TApresence.id_ap)
        )

        data = query.all()
        return [d._asdict() for d in data]

def get_habitats():
    # Subqueries
    habitat = (
        DB.session.query(
        cor_ap_physiognomy.c.id_ap,
        func.string_agg(TNomenclatures.label_default, ", ").label("type_habitat")
        )
        .join(TNomenclatures, TNomenclatures.id_nomenclature == cor_ap_physiognomy.c.id_nomenclature)
        .group_by(cor_ap_physiognomy.c.id_ap)
    ).cte("habitat")

    perturbation = (
        DB.session.query(
        CorApPerturbation.id_ap,
        func.string_agg(TNomenclatures.label_default, ", ").label("type_perturbation")
        )
        .join(TNomenclatures, TNomenclatures.id_nomenclature == CorApPerturbation.id_nomenclature)
        .group_by(CorApPerturbation.id_ap)
    ).cte("perturbation")

    # Execute query
    query = (
        DB.session.query(
            TApresence.id_ap.label("id-ap"),
            habitat.c.type_habitat.label("type-habitat"),
            perturbation.c.type_perturbation.label("type-perturbation"),
            TNomenclatures.label_default.label("evaluation-menace")
        )
        .outerjoin(habitat, habitat.c.id_ap == TApresence.id_ap)
        .outerjoin(perturbation, perturbation.c.id_ap == TApresence.id_ap)
        .outerjoin(TNomenclatures, TNomenclatures.id_nomenclature == TApresence.id_nomenclature_threat_level)
    )
