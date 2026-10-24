CREATE EXTENSION IF NOT EXISTS unaccent;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE OR REPLACE FUNCTION immutable_unaccent(p_text TEXT)
RETURNS TEXT AS $$
    SELECT public.unaccent('public.unaccent'::regdictionary, p_text);
$$ LANGUAGE sql IMMUTABLE PARALLEL SAFE STRICT
SET search_path = pg_catalog, public;

SELECT immutable_unaccent('Nhà vệ sinh') AS test;