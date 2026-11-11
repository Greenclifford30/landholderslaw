\set ON_ERROR_STOP on
BEGIN;
-- This deliberately narrow role is a test fixture, not a production grant model.
CREATE ROLE schema_privilege_probe NOLOGIN;
GRANT USAGE ON SCHEMA public TO schema_privilege_probe;
GRANT SELECT, INSERT, UPDATE ON matter_party_snapshots TO schema_privilege_probe;
GRANT USAGE, SELECT ON SEQUENCE matter_party_snapshots_id_seq TO schema_privilege_probe;
CREATE FUNCTION pg_temp.expect_denied(statement text) RETURNS void LANGUAGE plpgsql AS $$
BEGIN
 BEGIN EXECUTE statement;
 EXCEPTION WHEN insufficient_privilege THEN RETURN;
 END;
 RAISE EXCEPTION 'Expected insufficient privilege: %',statement;
END $$;
SET LOCAL ROLE schema_privilege_probe;
SELECT pg_temp.expect_denied('TRUNCATE matter_party_snapshots');
SELECT pg_temp.expect_denied('ALTER TABLE matter_party_snapshots DISABLE TRIGGER ALL');
SELECT pg_temp.expect_denied('DELETE FROM matter_party_snapshots');
SELECT pg_temp.expect_denied('UPDATE matter_number_counters SET last_value=1');
SELECT pg_temp.expect_denied('CREATE TABLE public.unauthorized_test(id bigint)');
RESET ROLE;
ROLLBACK;
\echo 'Limited-role privilege checks passed.'
