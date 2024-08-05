"""add export-zp

Revision ID: 48b28d926cb6
Revises: 8785387b4689
Create Date: 2024-08-02 17:47:39.051278

"""

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = "48b28d926cb6"
down_revision = "8785387b4689"
branch_labels = None
depends_on = None


def upgrade():
    op.execute(
        """
        CREATE OR REPLACE VIEW pr_priority_flora.export_zp
        AS

        WITH observers AS (
            SELECT
                tz.id_zp,
                string_agg(DISTINCT (roles.prenom_role || ' ' || roles.nom_role || ' (' || bo.nom_organisme || ')'), ', ') AS observers
            FROM pr_priority_flora.t_zprospect AS tz
                LEFT JOIN pr_priority_flora.cor_zp_obs AS observer
                ON observer.id_zp = tz.id_zp
                LEFT JOIN utilisateurs.t_roles AS roles
                ON roles.id_role = observer.id_role
                LEFT JOIN utilisateurs.bib_organismes AS bo
                ON bo.id_organisme = roles.id_organisme
            GROUP BY tz.id_zp
        ),
            municiplaties AS (
                SELECT
                    tz.id_zp,
                    string_agg(DISTINCT la.area_name, ', ') AS municipalities
                FROM pr_priority_flora.t_zprospect AS tz
                    LEFT JOIN pr_priority_flora.cor_zp_area AS czp
                    ON czp.id_zp = tz.id_zp
                    LEFT JOIN ref_geo.l_areas AS la
                    ON la.id_area = czp.id_area
                WHERE la.id_type = ref_geo.get_id_area_type('COM'::character varying)
                GROUP BY tz.id_zp
            )

        SELECT
            tz.id_zp AS id_zp,
            t.nom_complet AS sciname,
            tz.cd_nom AS sciname_code,
            tz.date_min AS date_min,
            tz.date_max AS date_max,
            obs.observers AS observaters,
            tz.geom_local AS zp_geom_local,
            tz.geom_4326 AS zp_geom_4326,
            tz.geom_point_4326 AS zp_geom_point_4326,
            public.ST_AsGeoJSON(tz.geom_4326) AS zp_geojson,
            tz."area" AS zp_surface,
            mun.municipalities
        FROM pr_priority_flora.t_zprospect AS tz
            LEFT JOIN municiplaties AS mun
                ON mun.id_zp = tz.id_zp
            LEFT JOIN observers AS obs
                ON obs.id_zp = tz.id_zp
            LEFT JOIN taxonomie.taxref AS t
            ON t.cd_nom = tz.cd_nom
        ;
        """
    )


def downgrade():
    op.execute(
        """
        DROP VIEW IF EXISTS pr_priority_flora.export_zp;
        """
    )
