-- CREATE EXTENSION cube;
-- CREATE EXTENSION earthdistance;

DO 
$ALL$
BEGIN

-- geoname Schema
IF NOT EXISTS (SELECT 1 FROM information_schema.schemata 
              WHERE schema_name = 'geoname') THEN
    CREATE SCHEMA geoname;
END IF;

-- geoname.geoname table
IF NOT EXISTS (SELECT 1 FROM information_schema.tables
              WHERE table_schema = 'geoname' AND
              table_name = 'geoname') THEN
    CREATE TABLE geoname.geoname (
        geo_id integer PRIMARY KEY,
	geo_name varchar(200),
	geo_lat numeric,
	geo_lng numeric,
	geo_feature_class varchar(1),
	geo_feature_code varchar(10),
	geo_adm1 varchar(20),
	geo_adm2 varchar(80),
	geo_adm3 varchar(20),
	geo_adm4 varchar(20),
	geo_population bigint,
	geo_elevation integer,
	geo_timezone varchar(40),
	geo_modification date,
	geo_level integer,
	geo_station_id integer
    );
END IF;

-- Indexes on geoname.geoname
IF NOT EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
               WHERE  c.relname = 'geoname_geo_feature_code_idx'
               AND    n.nspname = 'geoname') THEN
    CREATE INDEX geoname_geo_feature_code_idx ON geoname.geoname (geo_feature_code);
END IF;

IF NOT EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
               WHERE  c.relname = 'geoname_geo_adm4_idx'
               AND    n.nspname = 'geoname') THEN
    CREATE INDEX geoname_geo_adm4_idx ON geoname.geoname (geo_adm4 NULLS FIRST);
END IF;

-- geoname.zip table
IF NOT EXISTS (SELECT 1 FROM information_schema.tables
              WHERE table_schema = 'geoname' AND
              table_name = 'zip') THEN
    CREATE TABLE geoname.zip (
        zip_id serial PRIMARY KEY,
	zip_name varchar(200),
	zip_name_canon varchar(200),
	zip_adm3 varchar(20),
	zip_code varchar(20),
	zip_geoname integer,
	zip_isadm3 boolean default FALSE,
	zip_lat numeric,
	zip_lng numeric
    );
END IF;

IF NOT EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
               WHERE  c.relname = 'geoname_zip_name_canon_idx'
               AND    n.nspname = 'geoname') THEN
    CREATE INDEX geoname_zip_name_canon_idx ON geoname.zip (zip_name_canon);
END IF;


-- geoname.calendar table
IF NOT EXISTS (SELECT 1 FROM information_schema.tables
              WHERE table_schema = 'geoname' AND
              table_name = 'calendar') THEN
    CREATE TABLE geoname.calendar (
    	cal_date date PRIMARY KEY,
	cal_moonphase integer,
	cal_moon4 integer -- Quartiers de lune : 0=nouvelle, 1=premier, 2=pleine, 3=dernier
    );
END IF;

CREATE OR REPLACE FUNCTION geoname.geoname_geoname_add (
       prm_id integer, 
       prm_name varchar,
       prm_lat numeric,
       prm_lng numeric,
       prm_feature_class varchar,
       prm_feature_code varchar,
       prm_adm1 varchar,
       prm_adm2 varchar,
       prm_adm3 varchar,
       prm_adm4 varchar,
       prm_population bigint,
       prm_elevation integer,
       prm_timezone varchar(40),
       prm_modification date)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO geoname.geoname (
  	geo_id,	geo_name, geo_lat, geo_lng, geo_feature_class, geo_feature_code,
	geo_adm1, geo_adm2, geo_adm3, geo_adm4, geo_population, geo_elevation,
	geo_timezone, geo_modification) VALUES (prm_id,	prm_name, prm_lat, prm_lng,
	prm_feature_class, prm_feature_code, prm_adm1, prm_adm2, prm_adm3, prm_adm4,
	prm_population,	prm_elevation, prm_timezone, prm_modification);
END;
$$;

CREATE OR REPLACE FUNCTION geoname.geoname_geoname_set_level () 
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE geoname.geoname SET geo_level = 0 WHERE geo_feature_code = 'PPLC';
    UPDATE geoname.geoname SET geo_level = 1 WHERE geo_feature_code = 'PPLA';
    UPDATE geoname.geoname SET geo_level = 2 WHERE geo_feature_code = 'PPLA2';
    UPDATE geoname.geoname SET geo_level = 3 WHERE geo_feature_code = 'PPLA3';
    UPDATE geoname.geoname SET geo_level = 4 WHERE geo_feature_code = 'PPL';
END;
$$;

CREATE OR REPLACE FUNCTION geoname.geoname_geoname_set_station (prm_geo_id integer, prm_station_id integer) 
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE geoname.geoname SET geo_station_id = prm_station_id WHERE geo_id = prm_geo_id;
END;
$$;

CREATE OR REPLACE FUNCTION geoname.geoname_geoname_admin4_list ()
RETURNS SETOF geoname.geoname
LANGUAGE plpgsql
AS $$
DECLARE
  row geoname.geoname;
BEGIN
  FOR row IN
    SELECT geoname.* FROM geoname.geoname WHERE geo_feature_code = 'ADM4'
  LOOP
    RETURN NEXT row;
  END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION geoname.geoname_geoname_admin3_list ()
RETURNS SETOF geoname.geoname
LANGUAGE plpgsql
AS $$
DECLARE
  row geoname.geoname;
BEGIN
  FOR row IN
    SELECT geoname.* FROM geoname.geoname WHERE geo_feature_code = 'ADM3' AND geo_adm4 ISNULL
  LOOP
    RETURN NEXT row;
  END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION geoname.geoname_geoname_admin2_list ()
RETURNS SETOF geoname.geoname
LANGUAGE plpgsql
AS $$
DECLARE
  row geoname.geoname;
BEGIN
  FOR row IN
    SELECT geoname.* FROM geoname.geoname WHERE geo_feature_code = 'ADM2' AND geo_adm3 ISNULL
  LOOP
    RETURN NEXT row;
  END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION geoname.geoname_geoname_admin1_list ()
RETURNS SETOF geoname.geoname
LANGUAGE plpgsql
AS $$
DECLARE
  row geoname.geoname;
BEGIN
  FOR row IN
    SELECT geoname.* FROM geoname.geoname WHERE geo_feature_code = 'ADM1' AND geo_adm2 ISNULL
  LOOP
    RETURN NEXT row;
  END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION geoname.geoname_geoname_list (prm_level integer)
RETURNS SETOF geoname.geoname
LANGUAGE plpgsql
AS $$
DECLARE
  row geoname.geoname;
BEGIN
  FOR row IN
    SELECT geoname.* FROM geoname.geoname WHERE geo_level <= prm_level
  LOOP
    RETURN NEXT row;
  END LOOP;
END;
$$;

-- ##### ZIP #####
CREATE OR REPLACE FUNCTION geoname.geoname_zip_add (
       prm_name varchar,
       prm_adm3 varchar,
       prm_code varchar)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
	tmp_geoname integer;
BEGIN
  SELECT geo_id INTO tmp_geoname FROM geoname.geoname 
    WHERE geo_name = prm_name AND geo_adm3 = prm_adm3;
  INSERT INTO geoname.zip (zip_name, zip_adm3, zip_code, zip_geoname) 
    VALUES (prm_name, prm_adm3, prm_code, tmp_geoname);
END;
$$;

CREATE OR REPLACE FUNCTION geoname.geoname_zip_update_geoname ()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
	tmp_geoname integer;
	row geoname.zip;
BEGIN
  FOR row IN
    SELECT * FROM geoname.zip WHERE zip_geoname ISNULL
  LOOP
    SELECT geo_id INTO tmp_geoname FROM geoname.geoname 
      WHERE SOUNDEX(geo_name) = SOUNDEX(row.zip_name) AND geo_adm3 = row.zip_adm3;
    IF FOUND THEN
      UPDATE geoname.zip SET zip_geoname = tmp_geoname WHERE zip_id = row.zip_id;
    END IF;
  END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION geoname.geoname_zip_list (prm_code varchar)
RETURNS SETOF geoname.zip
LANGUAGE plpgsql
AS $$
DECLARE
	row geoname.zip;
BEGIN
  FOR row IN
    SELECT * FROM geoname.zip WHERE zip_code = prm_code
  LOOP
    RETURN NEXT row;
  END LOOP;
END;
$$;

DROP FUNCTION IF EXISTS geoname.geoname_zip_list2 (prm_code varchar);
DROP TYPE  IF EXISTS geoname.geoname_zip_list2;
CREATE TYPE geoname.geoname_zip_list2 AS (
  geoid integer,
  name varchar,
  zip varchar,
  level integer,
  stationid integer,
  station varchar
);
CREATE FUNCTION geoname.geoname_zip_list2 (prm_code varchar)
RETURNS SETOF geoname.geoname_zip_list2
LANGUAGE plpgsql
AS $$
DECLARE
	row geoname.geoname_zip_list2;
BEGIN
  FOR row IN
    SELECT zip_geoname, zip_name, zip_code, geoname.geo_level, geoname.geo_station_id, station.geo_name
      FROM geoname.zip
      INNER JOIN geoname.geoname ON geoname.geo_id = zip.zip_geoname
      INNER JOIN geoname.geoname station ON geoname.geo_station_id = station.geo_id
        WHERE zip_code = prm_code
  LOOP
    RETURN NEXT row;
  END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION geoname.geoname_zip_get (prm_geoname integer)
RETURNS geoname.zip
LANGUAGE plpgsql
AS $$
DECLARE
	row geoname.zip;
BEGIN
  SELECT * INTO row FROM geoname.zip WHERE zip_geoname = prm_geoname;
  RETURN row;
END;
$$;

CREATE OR REPLACE FUNCTION geoname.geoname_search (prm_q varchar)
RETURNS SETOF geoname.zip
LANGUAGE plpgsql
AS $$
DECLARE
	row geoname.zip;
BEGIN
  FOR row IN
    SELECT * FROM geoname.zip WHERE zip_name_canon like geoname.geoname_canon(prm_q) || '%'
  LOOP
    RETURN NEXT row;
  END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION geoname.geoname_search2 (prm_q varchar)
RETURNS SETOF geoname.geoname_zip_list2
LANGUAGE plpgsql
AS $$
DECLARE
	row geoname.geoname_zip_list2;
BEGIN
  FOR row IN
    SELECT zip_geoname, zip_name, zip_code, geoname.geo_level, geoname.geo_station_id, station.geo_name
      FROM geoname.zip
      INNER JOIN geoname.geoname ON geoname.geo_id = zip.zip_geoname
      INNER JOIN geoname.geoname station ON geoname.geo_station_id = station.geo_id
        WHERE zip_name_canon like geoname.geoname_canon(prm_q) || '%'
  LOOP
    RETURN NEXT row;
  END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION geoname.geoname_proche (prm_lat numeric, prm_lng numeric)
RETURNS geoname.geoname
LANGUAGE plpgsql
AS $$
DECLARE
	ret geoname.geoname;
BEGIN
    SELECT * INTO ret FROM geoname.geoname
--	   WHERE geo_level < 4
    	   ORDER BY POINT(prm_lng, prm_lat) <@> POINT (geo_lng, geo_lat) 
	   LIMIT 1;
    RETURN ret;
END;
$$;


CREATE OR REPLACE FUNCTION geoname.geoname_proche_geoid (prm_id integer)
RETURNS geoname.geoname
LANGUAGE plpgsql
AS $$
DECLARE
	ret geoname.geoname;
        inp geoname.geoname;
BEGIN
    SELECT * INTO inp FROM geoname.geoname WHERE geo_id = prm_id;
    IF inp.geo_level > 3 THEN
        SELECT * INTO ret FROM geoname.geoname
	   WHERE geo_level < 4
    	   ORDER BY POINT(inp.geo_lng, inp.geo_lat) <@> POINT (geo_lng, geo_lat) 
	   LIMIT 1;
        RETURN ret;
    ELSE
        RETURN inp;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION geoname.geoname_from_geoid (prm_id integer)
RETURNS geoname.geoname
LANGUAGE plpgsql
AS $$
DECLARE
        inp geoname.geoname;
BEGIN
    SELECT * INTO inp FROM geoname.geoname WHERE geo_id = prm_id;
    RETURN inp;
END;
$$;

CREATE OR REPLACE FUNCTION geoname.geoname_canon(str character varying)
RETURNS character varying 
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE

BEGIN
	RETURN LOWER (TRANSLATE (str,   ' ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ°«»#,()''+/.&"', 
	       	     			'-aaaaaaaaaaaaooooooooooooeeeeeeeecciiiiiiiiuuuuuuuuynn---d---------'));
END;
$$;


-- CALENDAR
CREATE OR REPLACE FUNCTION geoname.geoname_calendar_set_moonphase (
       prm_date date,
       prm_moonphase integer
       )
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE geoname.calendar SET cal_moonphase = prm_moonphase WHERE cal_date = prm_date;
  IF NOT FOUND THEN
    INSERT INTO geoname.calendar (cal_date, cal_moonphase) VALUES (prm_date, prm_moonphase);
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION geoname.geoname_calendar_set_moon4 (
       prm_date date,
       prm_moon4 integer
       )
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE geoname.calendar SET cal_moon4 = prm_moon4 WHERE cal_date = prm_date;
  IF NOT FOUND THEN
    INSERT INTO geoname.calendar (cal_date, cal_moon4) VALUES (prm_date, prm_moon4);
  END IF;
END;
$$;

END;
$ALL$
