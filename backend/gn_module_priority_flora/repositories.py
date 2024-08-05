from sqlalchemy import Date, Interval, and_, func, true
from sqlalchemy.orm import aliased
from sqlalchemy.sql.functions import concat
from sqlalchemy.sql.expression import select


from geonature.utils.env import db
from ref_geo.models import LAreas, BibAreasTypes
from apptax.taxonomie.models import Taxref
from pypnusershub.db.models import User
from pypnnomenclature.models import TNomenclatures

from .models import (
    TApresence,
    TZprospect,
    cor_zp_observer,
    cor_zp_area,
    CorApArea,
    cor_ap_physiognomy,
    CorApPerturbation,
)


def get_ap_export_mapping_columns():
    # Use this dictionary to define export columns order.
    # Change value to redefine or translate the exported column name.
    # Remove item to remove column from the export.
    return {
        "id_zp": "id_zp",
        "sciname": "taxon",
        "sciname_code": "cd_nom",
        "date_min": "date_min",
        "date_max": "date_max",
        "observaters": "observers",
        "zp_surface": "zp_surface",
        "zp_geom_local": "zp_geom_local",
        "id_ap": "id_ap",
        "municipalities": "municipalities",
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
        "total_min": "total_min",
        "total_max": "total_max",
        "comment": "remarque",
    }


def get_zp_export_mapping_columns():
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
        "zp_geom_local": "zp_geom_local",
        "zp_geom_4326": "zp_geom_4326",
        "zp_geom_point_4326": "zp_geom_point_4326",
        "zp_geojson": "zp_geojson",
        "zp_surface": "zp_surface",
        "municipalities": "communes",
    }


def get_ap_export_headers():
    return get_ap_export_mapping_columns().values()


def get_zp_export_headers():
    return get_zp_export_mapping_columns().values()


def translate_exported_columns(data):
    if "id_ap" in data :
        mapping_columns = get_ap_export_mapping_columns()
    else : 
        mapping_columns = get_zp_export_mapping_columns()
    translated_sorted_data = dict(
        (column_name, data[field])
        for (field, column_name) in mapping_columns.items()
        if field in data
    )
    return translated_sorted_data


class StatRepository:
    def __init__(self, cd_nom, area_code, area_type, date_start, years):
        self.cd_nom = cd_nom
        self.area_code = area_code
        self.area_type = area_type
        self.date_start = date_start
        self.years = years

    # Prepare subqueries for lateral joins
    def _get_departements_subquery(self):
        departements = (
                select(
                    cor_zp_area.c.id_zp,
                    func.string_agg(LAreas.area_name, ", ").label("area_name"),
                )
                .join(LAreas, LAreas.id_area == cor_zp_area.c.id_area)
                .filter(
                    cor_zp_area.c.id_zp == TZprospect.id_zp,
                    LAreas.id_type == func.ref_geo.get_id_area_type("DEP"),
                )
                .group_by(cor_zp_area.c.id_zp)
            .subquery()
            .lateral()
        )
        return departements

    def _get_municipalities_subquery(self):
        municipalities = (
            (
                select(
                    cor_zp_area.c.id_zp,
                    func.string_agg(LAreas.area_name, ", ").label("area_name"),
                )
                .join(LAreas, LAreas.id_area == cor_zp_area.c.id_area)
                .filter(
                    cor_zp_area.c.id_zp == TZprospect.id_zp,
                    LAreas.id_type == func.ref_geo.get_id_area_type("COM"),
                )
                .group_by(cor_zp_area.c.id_zp)
            )
            .subquery()
            .lateral()
        )
        return municipalities

    def _get_observers_subquery(self):
        observers = (
            (
                select(
                    cor_zp_observer.c.id_zp,
                    func.string_agg(func.concat(User.nom_role, " ", User.prenom_role), ", ").label(
                        "observers"
                    ),
                )
                .join(User, User.id_role == cor_zp_observer.c.id_role)
                .filter(cor_zp_observer.c.id_zp == TZprospect.id_zp)
                .group_by(cor_zp_observer.c.id_zp)
            )
            .subquery()
            .lateral()
        )
        return observers

    def _get_scinames_code_subquery(self):
        Taxref2 = aliased(Taxref)
        scinames_codes = (
            select(Taxref2.cd_nom)
            .join(Taxref, Taxref.cd_ref == Taxref2.cd_ref)
            .filter(Taxref.cd_nom == self.cd_nom)
        ).cte("scinames_codes")
        return scinames_codes

    def _get_habitat_type_subquery(self):
        habitat_type = (
            (
                select(
                    cor_ap_physiognomy.c.id_ap,
                    func.string_agg(TNomenclatures.label_default, ", ").label("type_habitat"),
                )
                .join(
                    TNomenclatures,
                    TNomenclatures.id_nomenclature == cor_ap_physiognomy.c.id_nomenclature,
                )
                .group_by(cor_ap_physiognomy.c.id_ap)
                .where(cor_ap_physiognomy.c.id_ap == TApresence.id_ap)
            )
            .subquery()
            .lateral()
        )
        return habitat_type

    def _get_perturbation_type_subquery(self):
        perturbation_type = (
            (
                select(
                    CorApPerturbation.id_ap,
                    func.string_agg(TNomenclatures.label_default, ", ").label("type_perturbation"),
                )
                .join(
                    TNomenclatures,
                    TNomenclatures.id_nomenclature == CorApPerturbation.id_nomenclature,
                )
                .group_by(CorApPerturbation.id_ap)
                .where(CorApPerturbation.id_ap == TApresence.id_ap)
            )
            .subquery()
            .lateral()
        )
        return perturbation_type

    def _get_apresence_subquery(self):
        tzprospect = aliased(TZprospect)
        apresence = (
            (
                select(tzprospect.id_zp, func.count(TApresence.id_ap).label("nb_ap"))
                .outerjoin(TApresence, TApresence.id_zp == tzprospect.id_zp)
                .where(tzprospect.id_zp == TZprospect.id_zp)
                .group_by(tzprospect.id_zp)
            )
            .subquery()
            .lateral()
        )
        return apresence

    def get_prospections(self):
        municipalities = self._get_municipalities_subquery()
        departements = self._get_departements_subquery()
        observers = self._get_observers_subquery()
        scinames_codes = self._get_scinames_code_subquery()
        apresence = self._get_apresence_subquery()

        # Execute query
        query = (
            select(
                TZprospect.id_zp.label("id"),
                TZprospect.date_max.label("date"),
                municipalities.c.area_name.label("municipality"),
                departements.c.area_name.label("departements"),
                observers.c.observers.label("observers"),
                apresence.c.nb_ap.label("presence_area_nb"),
            )
            .outerjoin(cor_zp_area, cor_zp_area.c.id_zp == TZprospect.id_zp)
            .outerjoin(LAreas, LAreas.id_area == cor_zp_area.c.id_area)
            .outerjoin(BibAreasTypes, BibAreasTypes.id_type == LAreas.id_type)
            .outerjoin(municipalities, true())
            .outerjoin(departements, true())
            .outerjoin(observers, true())
            .outerjoin(apresence, true())
        )

        # Filter with parameters
        if self.cd_nom:
            query = query.where(
                and_(TZprospect.cd_nom == self.cd_nom, TZprospect.cd_nom.in_(scinames_codes))
            )

        if self.area_code:
            query = query.where(LAreas.area_code == self.area_code)

        if self.area_type:
            query = query.where(BibAreasTypes.type_code == self.area_type)

        if self.date_start:
            query = query.where(TZprospect.date_max <= self.date_start)

        if self.years:
            date_interval = func.cast(concat(self.years, "YEARS"), Interval)
            previous_datetime = func.date(self.date_start) - date_interval
            previous_date = func.cast(previous_datetime, Date)
            query = query.where(TZprospect.date_min >= previous_date)

        data = db.session.execute(query).all()
        output = [d._asdict() for d in data]
        return output

    def get_populations(self):
        scinames_codes = self._get_scinames_code_subquery()
        municipalities = self._get_municipalities_subquery()

        # Aliased tables
        NomencEstimateMethod = aliased(TNomenclatures)
        NomencCountingType = aliased(TNomenclatures)

        # Execute query
        query = (
            select(
                TApresence.id_ap.label("id_ap"),
                TApresence.id_zp.label("id_zp"),
                TApresence.area.label("area_ap"),
                TApresence.frequency.label("occurrence_frequency"),
                ((TApresence.total_min + TApresence.total_max) / 2).label("count"),
                municipalities.c.area_name.label("municipality"),
                NomencEstimateMethod.label_default.label("estimate_method"),
                NomencCountingType.label_default.label("counting_type"),
            )
            .outerjoin(TZprospect, TZprospect.id_zp == TApresence.id_zp)
            .outerjoin(CorApArea, CorApArea.id_ap == TApresence.id_ap)
            .outerjoin(LAreas, LAreas.id_area == CorApArea.id_area)
            .outerjoin(BibAreasTypes, BibAreasTypes.id_type == LAreas.id_type)
            .outerjoin(municipalities, true())
            .outerjoin(
                NomencEstimateMethod,
                NomencEstimateMethod.id_nomenclature == TApresence.id_nomenclature_frequency_method,
            )
            .outerjoin(
                NomencCountingType,
                NomencCountingType.id_nomenclature == TApresence.id_nomenclature_counting,
            )
        )

        # Filter with parameters
        if self.cd_nom:
            query = query.where(
                and_(TZprospect.cd_nom == self.cd_nom, TZprospect.cd_nom.in_(scinames_codes))
            )

        if self.area_code:
            query = query.where(LAreas.area_code == self.area_code)

        if self.area_type:
            query = query.where(BibAreasTypes.type_code == self.area_type)

        if self.date_start:
            query = query.where(TZprospect.date_max <= self.date_start)

        if self.years:
            date_interval = func.cast(concat(self.years, "YEARS"), Interval)
            previous_datetime = func.date(self.date_start) - date_interval
            previous_date = func.cast(previous_datetime, Date)
            query = query.where(TZprospect.date_min >= previous_date)

        data = db.session.execute(query).all()
        output = [d._asdict() for d in data]
        return output

    def _get_habitats_infos_query(self):
        habitat_type = self._get_habitat_type_subquery()
        perturbation_type = self._get_perturbation_type_subquery()
        scinames_codes = self._get_scinames_code_subquery()

        TNomenclaturesHab = aliased(TNomenclatures)

        # Execute query
        query = (
            select(
                TApresence.id_ap.label("id_ap"),
                TApresence.id_zp.label("id_zp"),
                TApresence.area.label("area_ap"),
                TApresence.id_nomenclature_habitat.label("conservation_status"),
                habitat_type.c.type_habitat.label("habitat_type"),
                perturbation_type.c.type_perturbation.label("perturbation_type"),
                TNomenclatures.label_default.label("threat_level"),
                TNomenclatures.cd_nomenclature.label("threat_level_code"),
                TNomenclaturesHab.cd_nomenclature.label("habitat_favorable"),
            )
            .outerjoin(TZprospect, TZprospect.id_zp == TApresence.id_zp)
            .outerjoin(CorApArea, CorApArea.id_ap == TApresence.id_ap)
            .outerjoin(LAreas, LAreas.id_area == CorApArea.id_area)
            .outerjoin(BibAreasTypes, BibAreasTypes.id_type == LAreas.id_type)
            .outerjoin(habitat_type, true())
            .outerjoin(perturbation_type, true())
            .outerjoin(
                TNomenclatures,
                TNomenclatures.id_nomenclature == TApresence.id_nomenclature_threat_level,
            )
            .outerjoin(
                TNomenclaturesHab,
                TNomenclaturesHab.id_nomenclature == TApresence.id_nomenclature_habitat,
            )
        )

        # Filter with parameters
        if self.cd_nom:
            query = query.where(
                and_(TZprospect.cd_nom == self.cd_nom, TZprospect.cd_nom.in_(scinames_codes))
            )

        if self.area_code:
            query = query.where(LAreas.area_code == self.area_code)

        if self.area_type:
            query = query.where(BibAreasTypes.type_code == self.area_type)

        if self.date_start:
            query = query.where(TZprospect.date_max <= self.date_start)

        if self.years:
            date_interval = func.cast(concat(self.years, "YEARS"), Interval)
            previous_datetime = func.date(self.date_start) - date_interval
            previous_date = func.cast(previous_datetime, Date)
            query = query.where(TZprospect.date_min >= previous_date)

        return query

    def get_habitats(self):
        query = self._get_habitats_infos_query()
        data = db.session.execute(query).all()
        output = [d._asdict() for d in data]
        return output

    def get_calculations(self):
        query = self._get_habitats_infos_query()
        hab_infos = query.cte("hab_infos")

        threatened_stations = db.session.execute(
            select(func.sum(hab_infos.c.area_ap)).where(hab_infos.c.threat_level_code.in_(("2", "3")))
        ).scalar()

        habitats_favorables = db.session.execute(
            select(func.sum(hab_infos.c.area_ap)).where(hab_infos.c.habitat_favorable.like("1"))
        ).scalar()

        calculations_result = db.session.execute(
            select(
                func.count(func.distinct(hab_infos.c.id_zp)).label("nb_stations"),
                func.sum(hab_infos.c.area_ap).label("area_presence"),
                (threatened_stations / func.sum(hab_infos.c.area_ap) * 100).label("threat_level"),
                (habitats_favorables / func.sum(hab_infos.c.area_ap) * 100).label("habitat_favorable"),
            )
        ).first()

        output = {
            "nb_stations": calculations_result[0],
            "area_presence": calculations_result[1],
            "threat_level": calculations_result[2],
            "habitat_favorable": calculations_result[3],
        }

        return output
