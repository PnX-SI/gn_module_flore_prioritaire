
from geonature.utils.env import db
from geonature.core.ref_geo.models import LAreas

from datetime import date
from sqlalchemy import Date, Interval, func, true
from sqlalchemy.orm import aliased
from sqlalchemy.sql.functions import concat
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
from .utils import prepare_output

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

    def __init__(self, cd_nom, area_code, date_start, years):
        self.cd_nom = cd_nom
        self.area_code = area_code
        self.date_start = date_start
        self.years = years

    def get_prospections(self):
        # Prepare subqueries for lateral join
        commune = (
            db.session.query(
                cor_zp_area.c.id_zp,
                func.string_agg(LAreas.area_name, ", ").label("area_name"))
            .join(LAreas, LAreas.id_area == cor_zp_area.c.id_area)
            .filter(
                cor_zp_area.c.id_zp == TZprospect.id_zp,
                LAreas.id_type == func.ref_geo.get_id_area_type("COM"))
            .group_by(cor_zp_area.c.id_zp)
            ).subquery(
            ).lateral()

        departement = (
            db.session.query(
                cor_zp_area.c.id_zp,
                func.string_agg(LAreas.area_name, ", ").label("area_name"))
            .join(LAreas, LAreas.id_area == cor_zp_area.c.id_area)
            .filter(
                cor_zp_area.c.id_zp == TZprospect.id_zp,
                LAreas.id_type == func.ref_geo.get_id_area_type("DEP"))
            .group_by(cor_zp_area.c.id_zp)
            ).subquery(
            ).lateral()

        observateur = (
            db.session.query(
                cor_zp_observer.c.id_zp,
                func.string_agg(
                    func.concat(User.nom_role, " ", User.prenom_role), ", ").label("observateurs"))
            .join(User, User.id_role == cor_zp_observer.c.id_role)
            .filter(cor_zp_observer.c.id_zp == TZprospect.id_zp)
            .group_by(cor_zp_observer.c.id_zp)
            ).subquery(
            ).lateral()

        tzprospect = aliased(TZprospect)

        apresence = (
            db.session.query(
                tzprospect.id_zp,
                func.count(TApresence.id_ap).label("nb_ap"))
            .outerjoin(TApresence, TApresence.id_zp == tzprospect.id_zp)
            .filter(tzprospect.id_zp == TZprospect.id_zp)
            .group_by(tzprospect.id_zp)
            ).subquery(
            ).lateral()

        # Execute query
        query = (
            db.session.query(
                TZprospect.id_zp.label("id"),
                TZprospect.date_max.label("date"),
                commune.c.area_name.label("town"),
                departement.c.area_name.label("departement"),
                observateur.c.observateurs.label("observers"),
                apresence.c.nb_ap.label("has_presence_area")
            )
            .outerjoin(cor_zp_area, cor_zp_area.c.id_zp == TZprospect.id_zp)
            .outerjoin(LAreas, LAreas.id_area == cor_zp_area.c.id_area)
            .outerjoin(commune, true())
            .outerjoin(departement, true())
            .outerjoin(observateur, true())
            .outerjoin(apresence, true())
        )

        # Filter with parameters
        if self.cd_nom:
            query = query.filter(TZprospect.cd_nom == self.cd_nom)

        if self.area_code:
            query = query.filter(
                LAreas.area_code == self.area_code
                )

        if self.date_start:
            query = query.filter(TZprospect.date_max <= self.date_start)

        if self.years:
            date_interval = func.cast(concat(self.years, "YEARS"), Interval)
            previous_datetime = func.date(self.date_start) - date_interval
            previous_date = func.cast(previous_datetime, Date)
            query = query.filter(TZprospect.date_min >= previous_date)

        data = query.all()
        output = [d._asdict() for d in data]
        return prepare_output(output)

    def get_populations(self):
        # Prepare subqueries for lateral join
        commune = (
            db.session.query(
                CorApArea.id_ap,
                func.string_agg(LAreas.area_name, ", ").label("area_name"))
            .join(LAreas, LAreas.id_area == CorApArea.id_area)
            .filter(
                CorApArea.id_ap == TApresence.id_ap,
                LAreas.id_type == func.ref_geo.get_id_area_type("COM"))
            .group_by(CorApArea.id_ap)
            ).subquery(
            ).lateral()

        # Aliased tables
        TNomenclaturesF= aliased(TNomenclatures)
        TNomenclaturesC = aliased(TNomenclatures)

        # Execute query
        query = (
            db.session.query(
                TApresence.id_ap.label("id_ap"),
                TApresence.id_zp.label("id_zp"),
                TApresence.area.label("area_ap"),
                TApresence.frequency.label("occurrence_frequency"),
                ((TApresence.total_min+TApresence.total_max)/2).label("count"),
                commune.c.area_name.label("town"),
                TNomenclaturesF.label_default.label("estimate_method"),
                TNomenclaturesC.label_default.label("counting_type")
            )
            .outerjoin(TZprospect, TZprospect.id_zp == TApresence.id_zp)
            .outerjoin(CorApArea, CorApArea.id_ap == TApresence.id_ap)
            .outerjoin(LAreas, LAreas.id_area == CorApArea.id_area)
            .outerjoin(commune, true())
            .outerjoin(
                TNomenclaturesF,
                TNomenclaturesF.id_nomenclature == TApresence.id_nomenclature_frequency_method)
            .outerjoin(
                TNomenclaturesC,
                TNomenclaturesC.id_nomenclature == TApresence.id_nomenclature_counting)
        )

        # Filter with parameters
        if self.cd_nom:
            query = query.filter(TZprospect.cd_nom == self.cd_nom)

        if self.area_code:
            query = query.filter(LAreas.area_code == self.area_code)

        if self.date_start:
            query = query.filter(TZprospect.date_max <= self.date_start)

        if self.years:
            date_interval = func.cast(concat(self.years, "YEARS"), Interval)
            previous_datetime = func.date(self.date_start) - date_interval
            previous_date = func.cast(previous_datetime, Date)
            query = query.filter(TZprospect.date_min >= previous_date)

        data = query.all()
        output = [d._asdict() for d in data]
        return prepare_output(output)

    def get_habitats(self):
        # Prepare subqueries for lateral join
        habitat = (
            db.session.query(
                cor_ap_physiognomy.c.id_ap,
                func.string_agg(TNomenclatures.label_default, ", ").label("type_habitat")
            )
            .join(TNomenclatures,
                TNomenclatures.id_nomenclature == cor_ap_physiognomy.c.id_nomenclature)
            .group_by(cor_ap_physiognomy.c.id_ap)
            .filter(cor_ap_physiognomy.c.id_ap == TApresence.id_ap)
            ).subquery(
            ).lateral()

        perturbation = (
            db.session.query(
                CorApPerturbation.id_ap,
                func.string_agg(TNomenclatures.label_default, ", ").label("type_perturbation")
            )
            .join(TNomenclatures, TNomenclatures.id_nomenclature == CorApPerturbation.id_nomenclature)
            .group_by(CorApPerturbation.id_ap)
            .filter(CorApPerturbation.id_ap == TApresence.id_ap)
            ).subquery(
            ).lateral()

        # Execute query
        query = (
            db.session.query(
                TApresence.id_ap.label("id"),
                habitat.c.type_habitat.label("habitat_type"),
                perturbation.c.type_perturbation.label("perturbation_type"),
                TNomenclatures.label_default.label("threat_level")
            )
            .outerjoin(TZprospect, TZprospect.id_zp == TApresence.id_zp)
            .outerjoin(CorApArea, CorApArea.id_ap == TApresence.id_ap)
            .outerjoin(LAreas, LAreas.id_area == CorApArea.id_area)
            .outerjoin(habitat, true())
            .outerjoin(perturbation, true())
            .outerjoin(TNomenclatures,
                    TNomenclatures.id_nomenclature == TApresence.id_nomenclature_threat_level)
        )

        # Filter with parameters
        if self.cd_nom:
            query = query.filter(TZprospect.cd_nom == self.cd_nom)

        if self.area_code:
            query = query.filter(LAreas.area_code == self.area_code)

        if self.date_start:
            query = query.filter(TZprospect.date_max <= self.date_start)

        if self.years:
            date_interval = func.cast(concat(self.years, "YEARS"), Interval)
            previous_datetime = func.date(self.date_start) - date_interval
            previous_date = func.cast(previous_datetime, Date)
            query = query.filter(TZprospect.date_min >= previous_date)

        data = query.all()
        output = [d._asdict() for d in data]
        return prepare_output(output)
