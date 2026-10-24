BEGIN;

ALTER TABLE drawing_feature
    ADD COLUMN IF NOT EXISTS feature_type VARCHAR(50),
    ADD COLUMN IF NOT EXISTS name VARCHAR(150),
    ADD COLUMN IF NOT EXISTS style JSONB NOT NULL DEFAULT '{}'::jsonb;

UPDATE drawing_feature
SET feature_type = COALESCE(feature_type, NULLIF(btrim(properties->>'type', E' \t\n\r'), '')),
    name = COALESCE(name, NULLIF(LEFT(properties->>'name', 150), '')),
    style = style || jsonb_strip_nulls(jsonb_build_object(
        'height', CASE WHEN properties->>'height' ~ '^-?[0-9]+([.][0-9]+)?$'
                       THEN (properties->>'height')::DOUBLE PRECISION END,
        'base_height', CASE WHEN properties->>'base_height' ~ '^-?[0-9]+([.][0-9]+)?$'
                            THEN (properties->>'base_height')::DOUBLE PRECISION END
    ));

CREATE UNIQUE INDEX IF NOT EXISTS uq_thao_dien_floor1_vertical_link_label
    ON vertical_link (label)
    WHERE label LIKE 'TD_F1:%';

COMMIT;
