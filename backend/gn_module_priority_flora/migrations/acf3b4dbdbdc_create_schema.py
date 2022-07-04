"""Create schema

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
down_revision = "955c298bac7b"
branch_labels = None
depends_on = None


def upgrade():
    local_srid = (
        TParameters.query.filter_by(parameter_name="local_srid")
        .with_entities(TParameters.parameter_value)
        .one()
        .parameter_value
    )
    operations = text(
        importlib.resources.read_text(
            "gn_module_priority_flora.migrations.data", "schema.sql"
        )
    )
    op.get_bind().execute(operations, {"local_srid": int(local_srid)})


def downgrade():
    op.execute("DROP SCHEMA pr_priority_flora CASCADE")