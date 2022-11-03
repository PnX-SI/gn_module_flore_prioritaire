
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
