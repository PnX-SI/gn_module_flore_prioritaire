"""
   Spécification du schéma toml des paramètres de configurations
"""

from marshmallow import Schema, fields

datatable_zp_columns = [
    {"name": "Id", "prop": "id_zp", "width": 70},
    {"name": "Taxon", "prop": "taxonomy.nom_valide", "width": 350},
    {"name": "Date", "prop": "date_min", "width": 120},
    {"name": "Organisme", "prop": "organisms_list", "width": 400},
]
datatable_zp_messages = {
    "emptyMessage": "Aucune zone de prospection à afficher !",
    "totalMessage": "zone(s) de prospection",
}
datatable_ap_columns = [
    {"name": "Fréquence", "prop": "frequency"},
    {"name": "Altitude min", "prop": "altitude_min"},
    {"name": "Altitude max", "prop": "altitude_max"},
]
datatable_ap_messages = {
    "emptyMessage": "Aucune aire de présence sur cette zone de prospection !",
    "totalMessage": "aire(s) de présence",
}
export_available_format = ["csv", "geojson"]


class GnModuleSchemaConf(Schema):
    datatable_zp_columns = fields.List(
        fields.Dict(),
        load_default=datatable_zp_columns,
    )
    datatable_zp_messages = fields.Dict(load_default=datatable_zp_messages)
    datatable_ap_columns = fields.List(
        fields.Dict(),
        load_default=datatable_ap_columns,
    )
    datatable_ap_messages = fields.Dict(load_default=datatable_ap_messages)
    export_available_format = fields.List(
        fields.String(),
        load_default=export_available_format,
    )
    observers_list_code = fields.String(load_default="PRIORITY_FLORA")
    taxons_list_code = fields.String(load_default="PRIORITY_FLORA")
    zoom_center = fields.List(
        fields.Float(),
        load_default=[44.982667966765845, 6.062455200884894],
    )
    zoom = fields.Integer(load_default=10)
