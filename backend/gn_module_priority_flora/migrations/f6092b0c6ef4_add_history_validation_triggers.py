"""Add history and validation triggers

Revision ID: f6092b0c6ef4
Revises: d95854d81b68
Create Date: 2022-08-31 15:27:18.238742

"""
import importlib

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'f6092b0c6ef4'
down_revision = 'd95854d81b68' # add synthese triggers
branch_labels = None
depends_on = None


def upgrade():
    operations = sa.text(
        importlib.resources.read_text(
            "gn_module_priority_flora.migrations.data", "history_validation.sql"
        )
    )
    op.get_bind().execute(operations)


def downgrade():
    remove_validation_triggers()
    remove_history_triggers()
    remove_history_functions()
    delete_history_data()
    remove_history_locations()
    delete_validations()


def remove_validation_triggers():
    op.execute("DROP TRIGGER tri_insert_default_validation_status ON pr_priority_flora.t_apresence")


def remove_history_triggers():
    op.execute("DROP TRIGGER tri_log_insert_delete_t_zprospect ON pr_priority_flora.t_zprospect")
    op.execute("DROP TRIGGER tri_log_update_t_zprospect ON pr_priority_flora.t_zprospect")

    op.execute("DROP TRIGGER tri_insert_prospect_zone_observer ON pr_priority_flora.cor_zp_obs")
    op.execute("DROP TRIGGER tri_delete_prospect_zone_observer ON pr_priority_flora.cor_zp_obs")

    op.execute("DROP TRIGGER tri_log_update_t_apresence ON pr_priority_flora.t_apresence")
    op.execute("DROP TRIGGER tri_log_insert_delete_t_apresence ON pr_priority_flora.t_apresence")

    op.execute("DROP TRIGGER tri_delete_presence_area_perturbation ON pr_priority_flora.cor_ap_perturbation")
    op.execute("DROP TRIGGER tri_insert_presence_area_perturbation ON pr_priority_flora.cor_ap_perturbation")

    op.execute("DROP TRIGGER tri_delete_presence_area_physiognomy ON pr_priority_flora.cor_ap_physiognomy")
    op.execute("DROP TRIGGER tri_insert_presence_area_physiognomy ON pr_priority_flora.cor_ap_physiognomy")


def remove_history_functions():
    op.execute("DROP FUNCTION pr_priority_flora.add_prospect_zone_observers")
    op.execute("DROP FUNCTION pr_priority_flora.delete_prospect_zone_observers")

    op.execute("DROP FUNCTION pr_priority_flora.get_perturbations_ids")
    op.execute("DROP FUNCTION pr_priority_flora.build_perturbations")
    op.execute("DROP FUNCTION pr_priority_flora.add_presence_area_perturbation")
    op.execute("DROP FUNCTION pr_priority_flora.delete_presence_area_perturbation")

    op.execute("DROP FUNCTION pr_priority_flora.get_physiognomies_ids")
    op.execute("DROP FUNCTION pr_priority_flora.build_physiognomies")
    op.execute("DROP FUNCTION pr_priority_flora.add_presence_area_physiognomy")
    op.execute("DROP FUNCTION pr_priority_flora.delete_presence_area_physiognomy")


def delete_history_data():
    op.execute("""
        DELETE FROM gn_commons.t_history_actions
        WHERE id_table_location = gn_commons.get_table_location_id('pr_priority_flora', 't_apresence')
    """)
    op.execute("""
        DELETE FROM gn_commons.t_history_actions
        WHERE id_table_location = gn_commons.get_table_location_id('pr_priority_flora', 't_zprospect')
    """)


def remove_history_locations():
    op.execute("""
        DELETE FROM gn_commons.bib_tables_location
        WHERE "schema_name" = 'pr_priority_flora'
            AND table_name IN ('t_zprospect', 't_apresence')
    """)

def delete_validations():
    op.execute("""
        DELETE FROM gn_commons.t_validations
        WHERE uuid_attached_row IN (
            SELECT uuid_ap
            FROM pr_priority_flora.t_apresence
        )
    """)
