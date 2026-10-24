BEGIN;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM drawing_feature WHERE floor_id IS NULL) THEN
        RAISE EXCEPTION 'Cannot require drawing_feature.floor_id: rows with NULL floor_id exist';
    END IF;
END;
$$;

ALTER TABLE drawing_feature
    ALTER COLUMN floor_id SET NOT NULL;

COMMIT;
