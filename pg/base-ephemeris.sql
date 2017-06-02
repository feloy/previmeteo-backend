DO 
$ALL$
BEGIN

-- ephemeris schema
IF NOT EXISTS (SELECT 1 FROM information_schema.schemata 
              WHERE schema_name = 'ephemeris') THEN
    CREATE SCHEMA ephemeris;
END IF;

-- ephemeris.ephemeris table
IF NOT EXISTS (SELECT 1 FROM information_schema.tables
              WHERE table_schema = 'ephemeris' AND
              table_name = 'ephemeris') THEN
    CREATE TABLE ephemeris.ephemeris (
        eph_id serial PRIMARY KEY,
	geo_id integer,
	eph_time timestamp with time zone,
	eph_is_sun boolean,
	eph_is_rise boolean
    );
END IF;

-- IF NOT EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
--                WHERE  c.relname = 'ephemeris_eph_planet_idx'
--                AND    n.nspname = 'geoname') THEN
--     CREATE INDEX ephemeris_eph_planet_idx ON geoname.ephemeris (eph_planet);
-- END IF;

-- IF NOT EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
--                WHERE  c.relname = 'ephemeris_eph_time_idx'
--                AND    n.nspname = 'geoname') THEN
--     CREATE INDEX ephemeris_eph_time_idx ON geoname.ephemeris ((eph_time at time zone 'Europe/Paris'));
-- END IF;

-- IF NOT EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
--                WHERE  c.relname = 'ephemeris_eph_event_idx'
--                AND    n.nspname = 'geoname') THEN
--     CREATE INDEX ephemeris_eph_event_idx ON geoname.ephemeris (eph_event);
-- END IF;

IF NOT EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
               WHERE  c.relname = 'ephemeris_eph_all_idx'
               AND    n.nspname = 'ephemeris') THEN
    CREATE INDEX ephemeris_eph_all_idx ON ephemeris.ephemeris (geo_id, eph_is_sun, eph_time);
END IF;

-- EPHEMERIS 
CREATE OR REPLACE FUNCTION ephemeris.ephemeris_add (
       prm_geoname integer,
       prm_time timestamp with time zone,
       prm_is_sun boolean,
       prm_is_rise boolean)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO ephemeris.ephemeris (geo_id, eph_time, eph_is_sun, eph_is_rise) 
    VALUES (prm_geoname, prm_time, prm_is_sun, prm_is_rise);
END;
$$;

CREATE OR REPLACE FUNCTION ephemeris.ephemeris_get (
       prm_geoname integer,
       prm_date date,
       prm_is_sun boolean,
       prm_is_rise boolean)
RETURNS time without time zone
LANGUAGE plpgsql
AS $$
DECLARE
	ret time without time zone;
BEGIN
    SELECT eph_time at time zone 'Europe/Paris'
    FROM ephemeris.ephemeris WHERE
    geo_id = prm_geoname AND
    prm_is_sun = eph_is_sun AND
    prm_is_rise = eph_is_rise AND
    (eph_time at time zone 'Europe/Paris')::date = prm_date INTO ret;
    RETURN ret;
END;
$$;

CREATE OR REPLACE FUNCTION ephemeris.ephemeris_is_visible(prm_is_sun boolean, prm_geoname integer)
RETURNS boolean
LANGUAGE plpgsql 
AS $$
DECLARE
    ret boolean;
BEGIN
    SELECT eph_is_rise INTO ret FROM ephemeris.ephemeris 
    WHERE geo_id = prm_geoname
    AND eph_is_sun = prm_is_sun
    AND eph_time <= CURRENT_TIMESTAMP 
    ORDER BY eph_time DESC
    LIMIT 1;
    RETURN ret;
END;
$$;

DROP FUNCTION IF EXISTS ephemeris.ephemeris_get_all (prm_geoname integer, n integer);
DROP TYPE IF EXISTS ephemeris.ephemeris_get_all;
CREATE TYPE ephemeris.ephemeris_get_all AS (
  d date,
  sunrise time without time zone,
  sunset time without time zone,
  moonrise time without time zone,
  moonset time without time zone,
  moonphase integer,
  moon4 integer
);
CREATE FUNCTION ephemeris.ephemeris_get_all (prm_geoname integer, n integer)
RETURNS SETOF ephemeris.ephemeris_get_all
LANGUAGE plpgsql
AS $$
DECLARE
  d date;
  ret ephemeris.ephemeris_get_all;
BEGIN
  FOR i in 0..n LOOP
    d = CURRENT_TIMESTAMP::date + (i || ' days')::interval;
--  RAISE WARNING '%', d;
    SELECT d,
     (select * from ephemeris.ephemeris_get(prm_geoname, d, true, true)),
     (select * from ephemeris.ephemeris_get(prm_geoname, d, true, false)),
     (select * from ephemeris.ephemeris_get(prm_geoname, d, false, true)),
     (select * from ephemeris.ephemeris_get(prm_geoname, d, false, false)),
     (SELECT cal_moonphase FROM geoname.calendar WHERE cal_date = d),
     (SELECT cal_moon4 FROM geoname.calendar WHERE cal_date = d)
      INTO ret;
    RETURN NEXT ret;
  END LOOP;
END;
$$;

END;
$ALL$

