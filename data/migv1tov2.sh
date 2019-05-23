#!/bin/bash

. v1_compat.ini
. ../../../config/settings.ini

#Sur le serveur de GeoNature V2 : création du lien FDW avec la base GeoNature1 
sudo -n -u postgres -s psql -d $db_name -c "CREATE EXTENSION IF NOT EXISTS postgres_fdw;" > v1_compat.log
sudo chmod 777 v1_compat.log
sudo -n -u postgres -s psql -d $db_name -c "DROP SERVER IF EXISTS geonature1server CASCADE;" >> v1_compat.log
sudo -n -u postgres -s psql -d $db_name -c "CREATE SERVER geonature1server FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '$geonature1host', dbname '$geonature1db', port '$geonature1port');" >> v1_compat.log
sudo -n -u postgres -s psql -d $db_name -c "CREATE USER MAPPING FOR $user_pg SERVER geonature1server OPTIONS (user '$geonature1user', password '$geonature1userpass');" >> v1_compat.log
sudo -n -u postgres -s psql -d $db_name -c "ALTER SERVER geonature1server OWNER TO $user_pg;" >> v1_compat.log

sudo -n -u postgres -s psql -d geonature2db -c "CREATE SCHEMA florepatri;" >> v1_compat.log
sudo -n -u postgres -s psql -d geonature2db -c "IMPORT FOREIGN SCHEMA florepatri FROM SERVER geonature1server INTO florepatri;" >> v1_compat.log

export PGPASSWORD='$user_pg_pass';psql -h $db_host -U $user_pg -d $db_name -f 'v1tov2.sql' >> v1_compat.log

