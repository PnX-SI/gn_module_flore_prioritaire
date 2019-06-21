#!/bin/bash

. config/settings.ini

# Create log folder in module folders if it don't already exists
if [ ! -d 'var' ]
then
  mkdir var
fi

if [ ! -d 'var/log' ]
then
  mkdir var/log
fi

# Copy SQL files into /tmp system folder in order to edit it with variables
cp data/FP_nomenclatures.sql /tmp/FP_nomenclatures.sql
cp data/FP.sql /tmp/FP.sql

sudo sed -i "s/MY_SRID_WORLD/$srid_world/g" /tmp/FP.sql


# Create priority flora nomenclatures into ref_nomenclatures schema
export PGPASSWORD=$user_pg_pass;psql -h $db_host -U $user_pg -d $db_name -f /tmp/FP_nomenclatures.sql &>> var/log/install_bs.log

# Create  schema priority flora into GeoNature database
export PGPASSWORD=$user_pg_pass;psql -h $db_host -U $user_pg -d $db_name -f /tmp/FP.sql &>> var/log/install_bs.log

# Remove temporary files
rm /tmp/FP.sql
rm /tmp/FP_nomenclatures.sql
