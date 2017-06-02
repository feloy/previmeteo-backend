DO 
$ALL$
BEGIN

-- public.requete table
IF NOT EXISTS (SELECT 1 FROM information_schema.tables
              WHERE table_schema = 'public' AND
              table_name = 'requete') THEN
    CREATE TABLE requete (
        d date,
        n integer
    );
END IF;

CREATE OR REPLACE FUNCTION requete_add()
  RETURNS void AS
$BODY$
DECLARE
	now date;
BEGIN
	now = CURRENT_TIMESTAMP;
	IF NOT EXISTS (SELECT 1 FROM requete WHERE d = now) THEN
	   INSERT INTO requete (d, n) VALUES (now, 0);
	   END IF;
	   UPDATE requete SET n = n + 1 WHERE d = now;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

END;
$ALL$
