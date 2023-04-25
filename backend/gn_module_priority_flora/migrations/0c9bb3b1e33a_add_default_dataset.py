"""Add module default metadata (dataset, acquisition framework, source)

Revision ID: 0c9bb3b1e33a
Revises: acf3b4dbdbdc
Create Date: 2022-08-25 09:50:19.823369

"""
import importlib

from alembic import op
from sqlalchemy.sql import text

from gn_module_priority_flora import MODULE_CODE


# revision identifiers, used by Alembic.
revision = "0c9bb3b1e33a"
down_revision = None
branch_labels = "priority_flora_sample"
depends_on = ("acf3b4dbdbdc",)


def upgrade():
    operations = text(
        importlib.resources.read_text(
            "gn_module_priority_flora.migrations.data", "metadata.sql"
        )
    )

    op.get_bind().execute(operations)


def downgrade():

    op.execute(
            """
        DELETE FROM pr_priority_flora.t_zprospect z
        USING gn_meta.t_datasets t
        WHERE z.id_dataset = t.id_dataset AND t.dataset_name = 'Bilan stationnel'
        """
    )
    op.execute(
            """
        DELETE FROM gn_meta.t_datasets
        WHERE dataset_name = 'Bilan stationnel'
        """
    )
    op.execute(
            """
            DELETE FROM gn_meta.t_acquisition_frameworks
            WHERE acquisition_framework_name = 'Bilan stationnel'
            """
        )
    delete_taxonomy_list(MODULE_CODE)



def delete_taxonomy_list(sciname_list_code):
    operation = text(
        """
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
        """
    )
    op.get_bind().execute(operation, {"listCode": sciname_list_code})
