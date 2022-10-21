"""Add synthese triggers

Revision ID: d95854d81b68
Revises: 0c9bb3b1e33a
Create Date: 2022-08-25 09:51:03.466277

"""
import importlib

from alembic import op
from sqlalchemy.sql import text

from gn_module_priority_flora import MODULE_CODE


# revision identifiers, used by Alembic.
revision = "d95854d81b68"
down_revision = "0c9bb3b1e33a"  # add default dataset
branch_labels = None
depends_on = None


def upgrade():
    operations = text(
        importlib.resources.read_text("gn_module_priority_flora.migrations.data", "synthese.sql")
    )

    op.get_bind().execute(operations, {"moduleCode": MODULE_CODE})


def downgrade():
    op.get_bind().execute(
        text(
            """
            DELETE FROM gn_synthese.synthese
            WHERE id_module = gn_commons.get_id_module_bycode(:moduleCode)
                AND id_dataset = pr_priority_flora.get_dataset_id()
            """
        ),
        {"moduleCode": MODULE_CODE},
    )

    op.execute("DROP TRIGGER tri_insert_synthese_observer ON pr_priority_flora.cor_zp_obs")
    op.execute("DROP TRIGGER tri_delete_synthese_observer ON pr_priority_flora.cor_zp_obs")

    op.execute("DROP TRIGGER tri_delete_synthese_ap ON pr_priority_flora.t_apresence")
    op.execute("DROP TRIGGER tri_insert_synthese_ap ON pr_priority_flora.t_apresence")
    op.execute("DROP TRIGGER tri_update_synthese_ap ON pr_priority_flora.t_apresence")
    op.execute("DROP TRIGGER tri_update_synthese_zp ON pr_priority_flora.t_zprospect")

    op.execute("DROP FUNCTION pr_priority_flora.add_synthese_observers()")
    op.execute("DROP FUNCTION pr_priority_flora.delete_synthese_observers()")
    op.execute("DROP FUNCTION pr_priority_flora.insert_synthese_ap()")
    op.execute("DROP FUNCTION pr_priority_flora.update_synthese_ap()")
    op.execute("DROP FUNCTION pr_priority_flora.delete_synthese_ap()")
    op.execute("DROP FUNCTION pr_priority_flora.update_synthese_zp()")

    op.execute("DROP FUNCTION pr_priority_flora.get_life_stage")
    op.execute("DROP FUNCTION pr_priority_flora.get_counting_type")
    op.execute("DROP FUNCTION pr_priority_flora.build_observers")
    op.execute("DROP FUNCTION pr_priority_flora.get_observers_ids")
    op.execute("DROP FUNCTION pr_priority_flora.get_taxon_name")
