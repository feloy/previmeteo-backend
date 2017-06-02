DO 
$ALL$
BEGIN

-- forecast schema
IF NOT EXISTS (SELECT 1 FROM information_schema.schemata 
              WHERE schema_name = 'forecast') THEN
    CREATE SCHEMA forecast;
END IF;

-- forecast.forecast table
IF NOT EXISTS (SELECT 1 FROM information_schema.tables
              WHERE table_schema = 'forecast' AND
              table_name = 'forecast') THEN
    CREATE TABLE forecast.forecast (
        for_id serial PRIMARY KEY,
	geo_id integer,
	for_modtime timestamp with time zone,
	for_start timestamp with time zone,
	for_end timestamp with time zone,
	for_fiability integer,
	for_picto integer,
	for_tempe_min integer,
	for_tempe_max integer,
	for_nebu integer,
	for_nebu_phrase varchar,
	for_precip numeric,
	for_precip_phrase varchar,
	for_vent_moy integer,
	for_raf integer,
	for_dir integer,
	for_vent_phrase varchar,
	for_tempe integer,
	for_tempe_res integer,
	for_pression integer
    );
END IF;

CREATE OR REPLACE FUNCTION forecast.forecast_forecast_add (
	prm_geo_id integer,
	prm_modtime timestamp with time zone,
	prm_start timestamp with time zone,
	prm_duration_s integer,
	prm_fiability integer,
	prm_picto integer,
	prm_tempe_min integer,
	prm_tempe_max integer,
	prm_nebu integer,
	prm_nebu_phrase varchar,
	prm_precip numeric,
	prm_precip_phrase varchar,
	prm_vent_moy integer,
	prm_raf integer,
	prm_dir integer,
	prm_vent_phrase varchar,
	prm_tempe integer,
	prm_tempe_res integer,
	prm_pression integer)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
--    RAISE WARNING '% -> %', prm_start, prm_start + (prm_duration_s || ' s')::interval;
    -- Delete all past forecasts
    DELETE FROM forecast.forecast WHERE
        for_end < CURRENT_TIMESTAMP;

    DELETE FROM forecast.forecast WHERE
        geo_id = prm_geo_id AND
	for_start = prm_start AND
	for_end - for_start = (prm_duration_s || ' seconds')::interval;

    INSERT INTO forecast.forecast (
	geo_id,
	for_modtime,
	for_start,
	for_end,
	for_fiability,
	for_picto,
	for_tempe_min,
	for_tempe_max,
	for_nebu,
	for_nebu_phrase,
	for_precip,
	for_precip_phrase,
	for_vent_moy,
	for_raf,
	for_dir,
	for_vent_phrase,
	for_tempe,
	for_tempe_res,
	for_pression
    ) VALUES (
	prm_geo_id,
	prm_modtime,
	prm_start,
	prm_start + (prm_duration_s || ' s')::interval,
	prm_fiability,
	prm_picto,
	prm_tempe_min,
	prm_tempe_max,
	prm_nebu,
	prm_nebu_phrase,
	prm_precip,
	prm_precip_phrase,
	prm_vent_moy,
	prm_raf,
	prm_dir,
	prm_vent_phrase,
	prm_tempe,
	prm_tempe_res,
	prm_pression);


END;
$$;

DROP FUNCTION forecast.forecast_forecast_map (prm_level integer, prm_duration_h integer);
DROP TYPE IF EXISTS forecast.forecast_forecast_map;
CREATE TYPE forecast.forecast_forecast_map AS (
    geo_id integer,
    geo_name varchar,
    geo_lat numeric,
    geo_lng numeric,
    geo_level integer,
    for_picto integer,
    for_nebu_phrase varchar,
    for_precip_phrase varchar,
    for_tempe integer,
    for_tempe_res integer,
    for_pression integer,
    for_vent_moy integer,
    for_dir integer,
    is_day boolean,
    for_tempe_min integer,
    for_tempe_max integer
);

CREATE FUNCTION forecast.forecast_forecast_map (prm_level integer, prm_duration_h integer)
RETURNS SETOF forecast.forecast_forecast_map 
LANGUAGE plpgsql
AS $$
DECLARE
    row forecast.forecast_forecast_map;
BEGIN
    FOR row IN
        SELECT 
	    geo_id, geo_name, geo_lat, geo_lng, geo_level,
	    for_picto, for_nebu_phrase, for_precip_phrase, for_tempe, for_tempe_res, for_pression,
	    for_vent_moy, for_dir,
	    ephemeris.ephemeris_is_visible(true, geo_id),
	    for_tempe_min, for_tempe_max
	FROM forecast.forecast
        INNER JOIN geoname.geoname using(geo_id) 
        WHERE CURRENT_TIMESTAMP BETWEEN for_start AND for_end
	AND for_end-for_start = (prm_duration_h || ' hour')::interval 
	AND geo_level <= prm_level
    LOOP
        RETURN NEXT row;
    END LOOP;
END;
$$;

DROP FUNCTION IF EXISTS forecast.forecast_forecast_map_interval (prm_level integer, prm_duration_h integer);
DROP TYPE IF EXISTS forecast.forecast_forecast_map_interval;
CREATE TYPE forecast.forecast_forecast_map_interval AS (
  for_start_interval timestamp without time zone,
  for_end_interval timestamp without time zone
);

CREATE FUNCTION forecast.forecast_forecast_map_interval (prm_level integer, prm_duration_h integer)
RETURNS forecast.forecast_forecast_map_interval
LANGUAGE plpgsql
AS $$
DECLARE
    ret forecast.forecast_forecast_map_interval;
BEGIN
    SELECT 
	    MIN(for_start at time zone 'Europe/Paris'), 
	    MAX(for_end at time zone 'Europe/Paris') INTO ret
	FROM forecast.forecast
        INNER JOIN geoname.geoname using(geo_id) 
        WHERE CURRENT_TIMESTAMP BETWEEN for_start AND for_end
	AND for_end-for_start = (prm_duration_h || ' hour')::interval 
	AND geo_level <= prm_level;
    RETURN ret;
    
END;
$$;

DROP FUNCTION IF EXISTS forecast.forecast_forecast_geoid (prm_id integer, prm_duration_h integer);
DROP TYPE IF EXISTS forecast.forecast_forecast_geoid;
CREATE TYPE forecast.forecast_forecast_geoid AS (
    for_fiability integer,
    for_picto integer,
    for_nebu integer,
    for_nebu_phrase varchar,
    for_precip integer,
    for_precip_phrase varchar,
    for_tempe integer,
    for_tempe_res integer,
    for_pression integer,
    for_vent_moy integer,
    for_vent_raf integer,
    for_dir integer,
    for_tempe_min integer,
    for_tempe_max integer,
    for_start timestamp without time zone,
    for_end timestamp without time zone,
    for_duration integer
);

CREATE FUNCTION forecast.forecast_forecast_geoid (prm_id integer, prm_duration_h integer)
RETURNS SETOF forecast.forecast_forecast_geoid 
LANGUAGE plpgsql
AS $$
DECLARE
    row forecast.forecast_forecast_geoid;
BEGIN
    FOR row IN
        SELECT 
	    for_fiability, for_picto, for_nebu, for_nebu_phrase, (10*for_precip)::integer, for_precip_phrase, for_tempe, for_tempe_res, for_pression,
	    for_vent_moy, for_raf, for_dir,
	    for_tempe_min, for_tempe_max,
	    for_start at time zone 'Europe/Paris',
	    for_end at time zone 'Europe/Paris',
	    prm_duration_h
	FROM forecast.forecast 
        INNER JOIN geoname.geoname using(geo_id) 
	WHERE geo_id = prm_id
        AND CURRENT_TIMESTAMP < for_end
	AND for_end-for_start = (prm_duration_h || ' hour')::interval
	ORDER BY for_start
    LOOP
        RETURN NEXT row;
    END LOOP;
END;
$$;

END;
$ALL$
