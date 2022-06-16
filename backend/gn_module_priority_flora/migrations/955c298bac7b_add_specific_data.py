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
down_revision = 'acf3b4dbdbdc'
branch_labels = None
depends_on = None


def upgrade():
    operations = text(
        importlib.resources.read_text(
            "priority_flora.migrations.data", "data.sql"
        )
    )
    op.get_bind().execute(operations)


def downgrade():
    delete_nomenclatures("ETAT_HABITAT")
    delete_nomenclatures("TYPE_PENTE")
    delete_nomenclatures("TYPE_PHENOLOGIE")


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
