"""Add specific data (nomenclatures, taxonomy list, module infos)

Revision ID: 955c298bac7b
Revises: acf3b4dbdbdc
Create Date: 2022-06-14 11:58:17.392946

"""
import importlib
from csv import DictReader

from alembic import op
import sqlalchemy as sa
from sqlalchemy.sql import text

from utils_flask_sqla.migrations.utils import logger


# revision identifiers, used by Alembic.
revision = "955c298bac7b"
down_revision = None
branch_labels = "priority_flora"
# Add nomenclatures shared in conservation modules
depends_on = ("0a97fffb151c",)


"""
Insert CSV file into specified table.
If source columns are specified, CSV file in copied in a temporary table,
then data restricted to specified source columns are copied in final table.
"""


def copy_from_csv(
    f, schema, table, dest_cols="", source_cols=None, header=True, encoding=None, delimiter=None
):
    if dest_cols:
        dest_cols = " (" + ", ".join(dest_cols) + ")"
    if source_cols:
        final_table = table
        final_table_cols = dest_cols
        table = f"import_{table}"
        dest_cols = ""
        field_names = get_csv_field_names(f, encoding=encoding, delimiter=delimiter)
        op.create_table(
            table, *[sa.Column(c, sa.String) for c in map(str.lower, field_names)], schema=schema
        )

    options = ["FORMAT CSV"]
    if header:
        options.append("HEADER")
    if encoding:
        options.append(f"ENCODING '{encoding}'")
    if delimiter:
        options.append(f"DELIMITER E'{delimiter}'")
    options = ", ".join(options)
    cursor = op.get_bind().connection.cursor()
    cursor.copy_expert(
        f"""
        COPY {schema}.{table}{dest_cols}
        FROM STDIN WITH ({options})
    """,
        f,
    )

    if source_cols:
        source_cols = ", ".join(source_cols)
        op.execute(
            f"""
        INSERT INTO {schema}.{final_table}{final_table_cols}
          SELECT {source_cols}
            FROM {schema}.{table}
        ON CONFLICT DO NOTHING;
        """
        )
        op.drop_table(table, schema=schema)


def get_csv_field_names(f, encoding, delimiter):
    if encoding == "WIN1252":  # postgresql encoding
        encoding = "cp1252"  # python encoding
    # t = TextIOWrapper(f, encoding=encoding)
    reader = DictReader(f, delimiter=delimiter)
    field_names = reader.fieldnames
    # t.detach()  # avoid f to be closed on t garbage collection
    f.seek(0)
    return field_names


def upgrade():
    operations = text(
        importlib.resources.read_text("gn_module_priority_flora.migrations.data", "data.sql")
    )
    op.get_bind().execute(operations)

    with importlib.resources.open_text(
        "gn_module_priority_flora.migrations.data", "nomenclatures.csv"
    ) as csvfile:
        logger.info("Inserting perturbations and others Conservation nomenclatures…")
        copy_from_csv(
            csvfile,
            "ref_nomenclatures",
            "t_nomenclatures",
            dest_cols=(
                "id_type",
                "cd_nomenclature",
                "mnemonique",
                "label_default",
                "definition_default",
                "label_fr",
                "definition_fr",
                "id_broader",
                "hierarchy",
            ),
            source_cols=(
                "ref_nomenclatures.get_id_nomenclature_type(type_nomenclature_code)",
                "cd_nomenclature",
                "mnemonique",
                "label_default",
                "definition_default",
                "label_fr",
                "definition_fr",
                "ref_nomenclatures.get_id_nomenclature(type_nomenclature_code, cd_nomenclature_broader)",
                "hierarchy",
            ),
            header=True,
            encoding="UTF-8",
            delimiter=",",
        )


def downgrade():
    delete_nomenclatures("INCLINE_TYPE")
    delete_nomenclatures("PHYSIOGNOMY_TYPE")
    delete_nomenclatures("HABITAT_STATUS")
    delete_nomenclatures("THREAT_LEVEL")
    delete_nomenclatures("PHENOLOGY_TYPE")
    delete_nomenclatures("FREQUENCY_METHOD")
    delete_nomenclatures("COUNTING_TYPE")

    delete_source()


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




def delete_source():
    op.execute(
        """
            DELETE FROM gn_synthese.t_sources where name_source = 'Bilan stationnel v2'
        """
    )