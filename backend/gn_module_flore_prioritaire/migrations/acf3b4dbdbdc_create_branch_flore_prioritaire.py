"""Create branch gn_module_flore_prioritaire

Revision ID: acf3b4dbdbdc
Revises: 
Create Date: 2021-10-14 09:58:29.810801

"""
import importlib

from alembic import op
from sqlalchemy.sql import text

from geonature.core.gn_commons.models import TParameters

# revision identifiers, used by Alembic.
revision = "acf3b4dbdbdc"
down_revision = None
branch_labels = ("gn_module_flore_prioritaire",)
depends_on = ("f06cc80cc8ba",)  # GeoNature 2.7.5


def delete_nomenclatures(mnemonique):
    operation = text(
        """
        DELETE FROM ref_nomenclatures.t_nomenclatures
        WHERE id_type = (
            SELECT id_type 
            FROM ref_nomenclatures.bib_nomenclatures_types
            WHERE mnemonique = :mnemonique
        );
        DELETE FROM ref_nomenclatures.bib_nomenclatures_types
        WHERE mnemonique = :mnemonique
        """
    )
    op.get_bind().execute(operation, {"mnemonique": mnemonique})


def upgrade():
    local_srid = (
        TParameters.query.filter_by(parameter_name="local_srid")
        .with_entities(TParameters.parameter_value)
        .one()
        .parameter_value
    )
    operations = text(
        importlib.resources.read_text(
            "gn_module_flore_prioritaire.migrations.data", "FP.sql"
        )
    )
    op.get_bind().execute(operations, {"local_srid": local_srid})


def downgrade():
    op.execute("DROP SCHEMA pr_priority_flora CASCADE")
    delete_nomenclatures("ETAT_HABITAT")
    delete_nomenclatures("TYPE_PENTE")
    delete_nomenclatures("TYPE_PERTURBATION")
    delete_nomenclatures("TYPE_PHENOLOGIE")
