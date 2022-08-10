"""Add specific data

Revision ID: 955c298bac7b
Revises: acf3b4dbdbdc
Create Date: 2022-06-14 11:58:17.392946

"""
import importlib

from alembic import op
from sqlalchemy.sql import text


# revision identifiers, used by Alembic.
revision = '955c298bac7b'
down_revision = None
branch_labels = "priority_flora"
# Add nomenclatures shared in conservation modules
depends_on = ("0a97fffb151c",)


def upgrade():
    operations = text(
        importlib.resources.read_text(
            "gn_module_priority_flora.migrations.data", "data.sql"
        )
    )
    op.get_bind().execute(operations)


def downgrade():
    delete_nomenclatures("ETAT_HABITAT")
    delete_nomenclatures("TYPE_PENTE")
    delete_nomenclatures("TYPE_PHENOLOGIE")
    delete_nomenclatures("TYPE_COMPTAGE")
    delete_taxonomy_list("PRIORITY_FLORA")
    delete_module("PRIORITY_FLORA")


def delete_nomenclatures(mnemonique):
    operation = text("""
        DELETE FROM ref_nomenclatures.t_nomenclatures
        WHERE id_type = (
            SELECT id_type
            FROM ref_nomenclatures.bib_nomenclatures_types
            WHERE mnemonique = :mnemonique
        );
        DELETE FROM ref_nomenclatures.bib_nomenclatures_types
        WHERE mnemonique = :mnemonique
    """)
    op.get_bind().execute(operation, {"mnemonique": mnemonique})

def delete_taxonomy_list(sciname_list_code):
    operation = text("""
        -- Delete names list : taxonomie.bib_listes, taxonomie.cor_nom_liste, taxonomie.bib_noms
        WITH names_deleted AS (
            DELETE FROM taxonomie.cor_nom_liste WHERE id_liste IN (
                SELECT id_liste FROM taxonomie.bib_listes
                WHERE code_liste = :listCode
            )
            RETURNING id_nom
        )
        DELETE FROM taxonomie.bib_noms WHERE id_nom IN (
            SELECT id_nom FROM names_deleted
        );

        DELETE FROM taxonomie.bib_listes WHERE code_liste = :listCode;
    """)
    op.get_bind().execute(operation, {"listCode" : sciname_list_code})


def delete_module(module_code):
    operation = text("""
        -- Unlink module from dataset
        DELETE FROM gn_commons.cor_module_dataset
            WHERE id_module = (
                SELECT id_module
                FROM gn_commons.t_modules
                WHERE module_code = :moduleCode
            ) ;

        -- Uninstall module (unlink this module of GeoNature)
        DELETE FROM gn_commons.t_modules
            WHERE module_code = :moduleCode ;
    """)
    op.get_bind().execute(operation, {"moduleCode" : module_code})