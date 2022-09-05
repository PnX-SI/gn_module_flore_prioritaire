"""Add module default metadata (dataset, acquisition framework, source)

Revision ID: 0c9bb3b1e33a
Revises: acf3b4dbdbdc
Create Date: 2022-08-25 09:50:19.823369

"""
import importlib

from alembic import op
from sqlalchemy.sql import text

from gn_module_priority_flora import METADATA_CODE, METADATA_NAME, MODULE_CODE


# revision identifiers, used by Alembic.
revision = '0c9bb3b1e33a'
down_revision = 'acf3b4dbdbdc' # create schema
branch_labels = None
depends_on = None

def upgrade():
    operations = text(
        importlib.resources.read_text(
            "gn_module_priority_flora.migrations.data", "metadata.sql"
        )
    )

    op.get_bind().execute(operations, {
        "metadataName": METADATA_NAME,
        "metadataCode": METADATA_CODE,
    })


def downgrade():
    op.execute("""
        DELETE FROM gn_synthese.t_sources
        WHERE id_source = pr_priority_flora.get_source_id()
    """)
    op.execute("""
        DELETE FROM pr_priority_flora.t_zprospect
        WHERE id_dataset = pr_priority_flora.get_dataset_id()
    """)
    op.execute("""
        DELETE FROM gn_meta.t_datasets
        WHERE id_dataset = pr_priority_flora.get_dataset_id()
    """)
    op.get_bind().execute(text("""
        DELETE FROM gn_meta.t_acquisition_frameworks
        WHERE acquisition_framework_name = :metaDataName
    """), { "metaDataName": METADATA_NAME })

    op.execute("DROP FUNCTION pr_priority_flora.get_dataset_id")
    op.execute("DROP FUNCTION pr_priority_flora.get_source_id")

