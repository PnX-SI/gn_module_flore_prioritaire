-- Migrate data from migrate_v1_florepatri and migrate_v1_utilisateurs
-- into GeoNature v2 Priority Flora module schema.
-- Usage:
--  1. go to sql directory: cd backend/gn_module_priority_flora/migrations/data/migrate_v1_to_v2
--  2. migrate data with scripts #3 :
--    export PGPASSWORD="<db_pass>"; \
--      psql -h "<db_host>" -U "<db_user>" -d "<db_name>" -f "03_migrate_users.sql"
--
-- where:
-- - <db_pass>: GeoNature v2 database user password.
-- - <db_host>: GeoNature v2 database host name. Ex.: "localhost".
-- - <db_user>: GeoNature v2 database user name with write access. Ex.: "geonatadmin".
-- - <db_name>: GeoNature v2 database name. Ex.: "geonature2db".

BEGIN;


\echo '----------------------------------------------------------------------------'
\echo 'Insert organisms'
INSERT INTO utilisateurs.bib_organismes (
        nom_organisme,
        adresse_organisme,
        cp_organisme,
        ville_organisme,
        tel_organisme,
        fax_organisme,
        email_organisme
    )
    SELECT DISTINCT
        o.nom_organisme,
        nullif(o.adresse_organisme, ''),
        nullif(o.cp_organisme, ''),
        nullif(upper(o.ville_organisme), ''),
        regexp_replace(
            replace(
                nullif(
                    trim(both from o.tel_organisme),
                    ''
                ),
                '.',
                ' '
            ),
            '^([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})$',
            '\1 \2 \3 \4 \5'
        ),
        regexp_replace(
            replace(
                nullif(
                    trim(both from o.fax_organisme),
                    ''
                ),
                '.',
                ' '
            ),
            '^([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})$',
            '\1 \2 \3 \4 \5'
        ),
        nullif(o.email_organisme, '')
    FROM migrate_v1_utilisateurs.bib_organismes AS o
    WHERE NOT EXISTS (
            SELECT 'X'
            FROM utilisateurs.bib_organismes AS bo
            WHERE upper(bo.nom_organisme) = upper(o.nom_organisme)
        )
;


\echo '----------------------------------------------------------------------------'
\echo 'Refresh "bib_organismes" table sequence (=auto-increment)'
SELECT setval(
    'utilisateurs.bib_organismes_id_organisme_seq',
    (SELECT max(id_organisme) + 1 FROM utilisateurs.bib_organismes),
    true
) ;


\echo '----------------------------------------------------------------------------'
\echo 'Insert roles'
INSERT INTO utilisateurs.t_roles (
        groupe,
        identifiant,
        nom_role,
        prenom_role,
        desc_role,
        pass,
        email,
        id_organisme,
        remarques,
        active,
        champs_addi
    )
    SELECT DISTINCT
        mr.groupe,
        nullif(mr.identifiant, ''),
        nullif(upper(mr.nom_role), ''),
        nullif(mr.prenom_role, ''),
        nullif(mr.desc_role, ''),
        nullif(mr.pass, ''),
        nullif(mr.email, ''),
        (SELECT bo.id_organisme from utilisateurs.bib_organismes as bo where upper(bo.nom_organisme) = upper(mbo.nom_organisme)),
        'Imported from GeoNature v1.',
        True,
        json_build_object(
            'migrateOriginalInfos', json_build_object(
                'dateInsert', mr.date_insert,
                'dateUpdate', mr.date_update,
                'lastAccess', mr.dernieracces,
                'roleId', mr.id_role,
                'organismId', mr.id_organisme,
                'organismName', mbo.nom_organisme
            )
        )::jsonb
    FROM migrate_v1_utilisateurs.t_roles AS mr
        LEFT JOIN migrate_v1_utilisateurs.bib_organismes as mbo
            ON mbo.id_organisme = mr.id_organisme
    WHERE NOT EXISTS (
        SELECT 'X'
        FROM utilisateurs.t_roles AS u
        WHERE (
                upper(u.nom_role) = upper(mr.nom_role)
                AND upper(u.prenom_role) = upper(mr.prenom_role)
            )
    )
;


\echo '----------------------------------------------------------------------------'
\echo 'Create users UUID if not set'
UPDATE utilisateurs.t_roles
SET uuid_role = uuid_generate_v4()
WHERE uuid_role IS NULL
    AND remarques = 'Imported from GeoNature v1.';


\echo '----------------------------------------------------------------------------'
\echo 'Refresh "t_roles" table sequence (=auto-increment)'
SELECT setval(
    'utilisateurs.t_roles_id_role_seq',
    (SELECT max(id_role) + 1 FROM utilisateurs.t_roles),
    true
) ;


\echo '----------------------------------------------------------------------------'
\echo 'COMMIT if all goes well !'
COMMIT;
