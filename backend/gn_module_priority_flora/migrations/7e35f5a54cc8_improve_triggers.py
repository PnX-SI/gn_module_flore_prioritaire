"""improve triggers

Revision ID: 7e35f5a54cc8
Revises: 020cf10ad5d1
Create Date: 2023-10-17 17:12:50.105878

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = "7e35f5a54cc8"
down_revision = "020cf10ad5d1"
branch_labels = None
depends_on = None


def upgrade():
    op.execute(
        """
        CREATE OR REPLACE FUNCTION pr_priority_flora.get_source_id()
            RETURNS INTEGER
            LANGUAGE plpgsql
            IMMUTABLE
        AS
        $function$
            -- Function that return the id of the Source (gn_synthese.t_sources) of this module.
            -- USAGE: SELECT pr_priority_flora.get_source_id();
            DECLARE
                sourceId INTEGER;
            BEGIN
                SELECT id_source INTO sourceId
                FROM gn_synthese.t_sources
                JOIN gn_commons.t_modules using(id_module)
                WHERE module_code = 'PRIORITY_FLORA'
                LIMIT 1 ;

                RETURN sourceId ;
            END;
        $function$ ;

        CREATE OR REPLACE FUNCTION pr_priority_flora.update_synthese_zp()
        RETURNS trigger AS
        $BODY$
        DECLARE
            presenceArea RECORD;

        BEGIN
            FOR presenceArea IN (
            SELECT ap.id_ap
            FROM pr_priority_flora.t_zprospect AS zp
                JOIN pr_priority_flora.t_apresence AS ap
                ON ap.id_zp = zp.id_zp
            WHERE ap.id_zp = NEW.id_zp
            )  LOOP
                -- Update synthese
                UPDATE gn_synthese.synthese SET
                unique_id_sinp_grp = NEW.uuid_zp,
                cd_nom = NEW.cd_nom,
                nom_cite = pr_priority_flora.get_taxon_name(NEW.id_zp),
                date_min = NEW.date_min,
                date_max = NEW.date_max,
                last_action = 'U',
                id_dataset = NEW.id_dataset
                WHERE id_source = pr_priority_flora.get_source_id()
                AND entity_source_pk_value = CAST(presenceArea.id_ap AS VARCHAR) ;
            END LOOP;

            RETURN NULL; -- Result is ignored since this is an AFTER trigger
        END;
        $BODY$
        LANGUAGE plpgsql VOLATILE
        COST 100;

    """
    )


def downgrade():
    op.execute(
        """
        CREATE OR REPLACE FUNCTION pr_priority_flora.get_source_id()
            RETURNS INTEGER
            LANGUAGE plpgsql
            IMMUTABLE
        AS
        $function$
            -- Function that return the id of the Source (gn_synthese.t_sources) of this module.
            -- USAGE: SELECT pr_priority_flora.get_source_id();
            DECLARE
                sourceId INTEGER;
            BEGIN
                SELECT id_source INTO sourceId
                FROM gn_synthese.t_sources
                WHERE name_source = :metadataName
                LIMIT 1 ;

                RETURN sourceId ;
            END;
        $function$ ;

CREATE OR REPLACE FUNCTION pr_priority_flora.update_synthese_zp()
RETURNS trigger AS
$BODY$
  DECLARE
    presenceArea RECORD;

  BEGIN
    FOR presenceArea IN (
      SELECT ap.id_ap
      FROM pr_priority_flora.t_zprospect AS zp
        JOIN pr_priority_flora.t_apresence AS ap
          ON ap.id_zp = zp.id_zp
      WHERE ap.id_zp = NEW.id_zp
    )  LOOP
        -- Update synthese
        UPDATE gn_synthese.synthese SET
          unique_id_sinp_grp = NEW.uuid_zp,
          cd_nom = NEW.cd_nom,
          nom_cite = pr_priority_flora.get_taxon_name(NEW.id_zp),
          date_min = NEW.date_min,
          date_max = NEW.date_max,
          last_action = 'U'
        WHERE id_source = pr_priority_flora.get_source_id()
          AND entity_source_pk_value = CAST(presenceArea.id_ap AS VARCHAR) ;
    END LOOP;

    RETURN NULL; -- Result is ignored since this is an AFTER trigger
  END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

    """
    )
