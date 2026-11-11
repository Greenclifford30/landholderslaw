\set ON_ERROR_STOP on
-- Report foreign keys with no valid, non-partial index whose leading keys are
-- the referencing columns in order. Included attributes are not key columns.
SELECT c.conrelid::regclass AS table_name,c.conname AS foreign_key,pg_get_constraintdef(c.oid) AS definition
FROM pg_constraint c
WHERE c.contype='f' AND c.connamespace='public'::regnamespace
AND NOT EXISTS (
 SELECT 1 FROM pg_index i WHERE i.indrelid=c.conrelid AND i.indisvalid AND i.indisready AND i.indpred IS NULL
 AND i.indnkeyatts >= cardinality(c.conkey)
 AND array_to_string((i.indkey::smallint[])[0:cardinality(c.conkey)-1],',') = array_to_string(c.conkey,',')
)
ORDER BY 1,2;

DO $$
BEGIN
 IF EXISTS (
  SELECT 1 FROM pg_constraint c
  WHERE c.contype='f' AND c.connamespace='public'::regnamespace
    AND NOT EXISTS (
      SELECT 1 FROM pg_index i WHERE i.indrelid=c.conrelid AND i.indisvalid AND i.indisready AND i.indpred IS NULL
      AND i.indnkeyatts >= cardinality(c.conkey)
      AND array_to_string((i.indkey::smallint[])[0:cardinality(c.conkey)-1],',') = array_to_string(c.conkey,',')
    )
 ) THEN RAISE EXCEPTION 'Foreign keys without a supporting leading-column index'; END IF;
END $$;
