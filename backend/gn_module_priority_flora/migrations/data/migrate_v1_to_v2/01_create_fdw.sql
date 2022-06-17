-- Create schemas migrate_v1_florepatri and migrate_v1_utilisateurs with FDW.
-- Usage:
--  1. go to sql directory: cd backend/gn_module_priority_flora/migrations/data/migrate_v1_to_v2
--  2. create FDW schema with scripts #1 :
-- sudo -n -u <pg_admin_name> -s \
--  psql -d "<db_name>" \
--     -v gn1DbHost="<gn1_db_host>" \
--     -v gn1DbName="<gn1_db_name>" \
--     -v gn1DbPort="<gn1_db_port>" \
--     -v gn1DbUser="<gn1_db_user>" \
--     -v gn1DbPass="<gn1_db_pass>" \
--     -v dbUser="<db_user>" \
--     -f "01_create_fdw.sql"
--
-- where:
-- - <pg_admin_name>: name of a GeoNature v2 database superuser. Ex.: "postgres".
-- - <db_name>: GeoNature v2 database name. Ex.: "geonature2db".
-- - <gn1_db_host>: server IP of GeoNature v1 database. Ex.: "213.32.78.105".
-- - <gn1_db_name>: GeoNature v1 database name. Ex.: "appli_flore".
-- - <gn1_db_port>: GeoNature v1 database port. Ex.: "5432".
-- - <gn1_db_user>: GeoNature v1 database user name with at least read access. Ex.: "reader".
-- - <gn1_db_pass>: GeoNature v1 database user password.
-- - <db_user>: GeoNature v2 database user name with write access. Ex.: "geonatadmin".

BEGIN;

\echo '----------------------------------------------------------------------------'
\echo 'Add FDW extension if necessary'
CREATE EXTENSION IF NOT EXISTS postgres_fdw;


\echo '----------------------------------------------------------------------------'
\echo 'Create FDW server'
DROP SERVER IF EXISTS geonaturev1server CASCADE;

CREATE SERVER geonaturev1server
    FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (
        host :'gn1DbHost',
        dbname :'gn1DbName',
        port :'gn1DbPort'
    );

ALTER SERVER geonaturev1server OWNER TO :dbUser;


\echo '----------------------------------------------------------------------------'
\echo 'Create user mapping'
DROP USER MAPPING IF EXISTS FOR :dbUser SERVER geonaturev1server;

CREATE USER MAPPING FOR :dbUser
    SERVER geonaturev1server
    OPTIONS (user :'gn1DbUser', password :'gn1DbPass');


\echo '----------------------------------------------------------------------------'
\echo 'Drop FDW schema if exists'
DROP SCHEMA IF EXISTS migrate_v1_florepatri;

DROP SCHEMA IF EXISTS migrate_v1_utilisateurs;


\echo '----------------------------------------------------------------------------'
\echo 'Change role from superuser to local user'
SET ROLE :dbUser;


\echo '----------------------------------------------------------------------------'
\echo 'Create FDW "migrate_v1_florepatri" schema'
CREATE SCHEMA migrate_v1_florepatri;

IMPORT FOREIGN SCHEMA florepatri
FROM SERVER geonaturev1server
INTO migrate_v1_florepatri;


\echo '----------------------------------------------------------------------------'
\echo 'Create FDW "migrate_v1_utilisateurs" schema'
CREATE SCHEMA migrate_v1_utilisateurs;

IMPORT FOREIGN SCHEMA utilisateurs
FROM SERVER geonaturev1server
INTO migrate_v1_utilisateurs;


\echo '----------------------------------------------------------------------------'
\echo 'COMMIT if all goes well !'
COMMIT;
