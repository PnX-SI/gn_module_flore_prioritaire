"""
   Spécification du schéma toml des paramètres de configurations
"""

from marshmallow import Schema, fields

available_export_format = ["csv", "shapefile"]

zp_message = {
    "emptyMessage": "Aucune zone à afficher ",
    "totalMessage": "zone(s) de prospection au total",
}
list_ap_message = {
    "emptyMessage": "Aucune aire de présence sur cette zone de prospection ",
    "totalMessage": "aire(s) de présence au total",
}
detail_list_ap_message = {
    "emptyMessage": "Aucune autre visite sur ce site ",
    "totalMessage": "visites au total",
}

default_zp_columns = [
    {"name": "Identifiant", "prop": "indexzp", "width": 90},
    {"name": "Taxon", "prop": "taxonomy.nom_valide", "width": 350},
    {"name": "Date min", "prop": "date_min", "width": 160},
    {"name": "Organisme", "prop": "organisms_list", "width": 200},
]

default_ap_columns = [
    {"name": "Fréquence", "prop": "frequency"},
    {"name": "Altitude min", "prop": "altitude_min"},
    {"name": "Altitude max", "prop": "altitude_max"},
]

coor_zoom_center = [44.982667966765845, 6.062455200884894]
zoom = 10


class GnModuleSchemaConf(Schema):
    zp_message = fields.Dict(load_default=zp_message)
    list_ap_message = fields.Dict(load_default=list_ap_message)
    detail_list_ap_message = fields.Dict(load_default=detail_list_ap_message)
    export_available_format = fields.List(
        fields.String(), load_default=available_export_format
    )
    default_zp_columns = fields.List(fields.Dict(), load_default=default_zp_columns)
    default_ap_columns = fields.List(fields.Dict(), load_default=default_ap_columns)
    id_type_maille = fields.Integer(load_default=32)
    id_type_commune = fields.Integer(load_default=25)
    id_menu_list_user = fields.Integer(load_default=1)
    code_liste_taxon = fields.String()
    export_srid = fields.Integer(load_default=2154)
    zoom_center = fields.List(fields.Float(), load_default=coor_zoom_center)
    zoom = fields.Integer(load_default=10)