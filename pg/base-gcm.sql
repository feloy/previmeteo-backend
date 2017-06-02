DO 
$ALL$
BEGIN

-- gcm schema
IF NOT EXISTS (SELECT 1 FROM information_schema.schemata 
              WHERE schema_name = 'gcm') THEN
    CREATE SCHEMA gcm;
END IF;

IF NOT EXISTS (SELECT 1 FROM information_schema.tables
              WHERE table_schema = 'gcm' AND
              table_name = 'register') THEN
    CREATE TABLE gcm.register (
       reg_id serial PRIMARY KEY,
       reg_key varchar,
       reg_account varchar
    );
END IF;

IF NOT EXISTS (SELECT 1 FROM information_schema.tables
              WHERE table_schema = 'gcm' AND
              table_name = 'register_geo') THEN
    CREATE TABLE gcm.register_geo (
       rgg_id serial PRIMARY KEY,
       reg_id integer REFERENCES gcm.register,
       geo_id integer REFERENCES geoname.geoname,
       geo_id_station integer REFERENCES geoname.geoname(geo_id)
    );
END IF;

CREATE OR REPLACE FUNCTION gcm.gcm_register_set(prm_reg_key varchar, prm_account varchar, prm_geo_ids integer[])
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    the_reg_id integer;
BEGIN
  SELECT reg_id INTO the_reg_id FROM gcm.register WHERE reg_key = prm_reg_key;
  IF NOT FOUND THEN
    INSERT INTO gcm.register (reg_key, reg_account) VALUES (prm_reg_key, prm_account)
      RETURNING reg_id INTO the_reg_id;
  ELSE
    DELETE FROM gcm.register_geo WHERE reg_id = the_reg_id;
  END IF;
  IF prm_geo_ids NOTNULL THEN
    FOR i IN 1 .. array_upper(prm_geo_ids, 1) LOOP
      INSERT INTO gcm.register_geo (reg_id, geo_id, geo_id_station) 
        VALUES (the_reg_id, prm_geo_ids[i], (SELECT geo_station_id FROM geoname.geoname WHERE geo_id = prm_geo_ids[i]));
    END LOOP;
  END IF;
  RETURN the_reg_id;
END;
$$;

CREATE OR REPLACE FUNCTION gcm.gcm_register_list_geoids (prm_key varchar)
RETURNS SETOF integer
LANGUAGE plpgsql
AS $$
DECLARE
  row RECORD;
BEGIN
  FOR row IN
    SELECT geo_id FROM gcm.register_geo
      INNER JOIN gcm.register USING(reg_id)
      WHERE reg_key = prm_key
  LOOP
    RETURN NEXT row.geo_id;
  END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION gcm.gcm_register_list_stations_geoids (prm_key varchar)
RETURNS SETOF integer
LANGUAGE plpgsql
AS $$
DECLARE
  row RECORD;
  geo geoname.geoname;
BEGIN
  FOR row IN
    SELECT geo_id FROM gcm.register_geo
      INNER JOIN gcm.register USING(reg_id)
      WHERE reg_key = prm_key
  LOOP
    SELECT * INTO geo FROM geoname.geoname_proche_geoid(row.geo_id);
    RETURN NEXT geo.geo_id;
  END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION gcm.gcm_register_list_from_station_id(prm_station_id integer)
RETURNS SETOF varchar
LANGUAGE plpgsql
AS $$
DECLARE
  row RECORD;
BEGIN
  FOR row IN
    SELECT DISTINCT reg_key FROM gcm.register
    INNER JOIN gcm.register_geo USING(reg_id)
    WHERE geo_id_station = prm_station_id AND reg_key NOTNULL
  LOOP
    RETURN NEXT row.reg_key;
  END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION gcm.gcm_register_delete (prm_key varchar)
RETURNS VOID 
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM gcm.register_geo WHERE reg_id = (SELECT reg_id FROM gcm.register WHERE reg_key = prm_key);
  DELETE FROM gcm.register WHERE reg_key = prm_key;
END;
$$;

END;
$ALL$

