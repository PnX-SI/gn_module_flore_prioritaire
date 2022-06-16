"""Add nomenclatures shared in conservation modules

Revision ID: 0a97fffb151c
Revises: None
Create Date: 2022-06-14 11:30:26.775634

"""
import importlib

from alembic import op
from sqlalchemy.sql import text

from utils_flask_sqla.migrations.utils import logger


# revision identifiers, used by Alembic.
revision = '0a97fffb151c'
down_revision = None
branch_labels = "nomenclatures_shared_in_conservation_modules"
depends_on = (
    "f06cc80cc8ba", # GeoNature 2.7.5
    #"b820c66d8daa", # nomenclatures head
)


def upgrade():
    cursor = op.get_bind().connection.cursor()
    with importlib.resources.open_text(
        "gn_module_priority_flora.migrations.data", "perturbation_nomenclatures.csv"
    ) as csvfile:
        logger.info("Inserting perturbations nomenclatures…")
        cursor.copy_expert(f'COPY ref_nomenclatures.t_nomenclatures FROM STDIN', csvfile)


def downgrade():
    delete_nomenclatures("TYPE_PERTURBATION")


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
