#! /bin/sh
. ../config.sh
PGPASSWORD=$pgpass psql -h $pghost -U $pguser $pgbase < base.sql
#PGPASSWORD=$pgpass psql -h $pghost -U $pguser $pgbase < base-forecast.sql
#PGPASSWORD=$pgpass psql -h $pghost -U $pguser $pgbase < base-ephemeris.sql
#PGPASSWORD=$pgpass psql -h $pghost -U $pguser $pgbase < base-gcm.sql
#PGPASSWORD=$pgpass psql -h $pghost -U $pguser $pgbase < base-public.sql
