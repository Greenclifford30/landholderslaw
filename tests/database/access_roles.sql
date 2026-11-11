\set ON_ERROR_STOP on
BEGIN;
CREATE FUNCTION pg_temp.expect_denied(statement text) RETURNS void LANGUAGE plpgsql AS $$
BEGIN
 BEGIN EXECUTE statement;
 EXCEPTION WHEN insufficient_privilege THEN RETURN;
 END;
 RAISE EXCEPTION 'Expected insufficient privilege: %',statement;
END $$;
DO $$
BEGIN
 IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname IN ('ll_app','ll_migrator','ll_db_admin') AND (rolcanlogin OR rolsuper OR rolcreatedb OR rolcreaterole OR rolreplication OR rolbypassrls)) THEN
  RAISE EXCEPTION 'Role capabilities exceed intended NOLOGIN baseline';
 END IF;
 IF pg_has_role('ll_app','ll_migrator','MEMBER') OR pg_has_role('ll_app','ll_db_admin','MEMBER') THEN
  RAISE EXCEPTION 'App role must not be an administrative member';
 END IF;
END $$;
SET LOCAL ROLE ll_migrator;
CREATE FUNCTION public.__test_default_execute() RETURNS integer LANGUAGE sql AS 'SELECT 1';
RESET ROLE;
SET SESSION AUTHORIZATION ll_app;
SELECT pg_temp.expect_denied('CREATE TABLE public.unauthorized_test(id bigint)');
SELECT pg_temp.expect_denied('SELECT public.__test_default_execute()');
SELECT pg_temp.expect_denied('ALTER TABLE public.matters DISABLE TRIGGER ALL');
SELECT pg_temp.expect_denied('TRUNCATE public.audit_events');
SELECT pg_temp.expect_denied('DELETE FROM public.audit_events');
SELECT pg_temp.expect_denied('UPDATE public.matter_number_counters SET last_value=99');
SELECT pg_temp.expect_denied('INSERT INTO public.matter_number_allocations(reference_year,sequence_value,allocation_token) VALUES (2041,1,''d0000000-0000-0000-0000-000000000001'')');
SELECT pg_temp.expect_denied('INSERT INTO public.matters(public_id,number_allocation_id,created_by) VALUES (''d0000000-0000-0000-0000-000000000002'',1,1)');
SELECT pg_temp.expect_denied('SELECT * FROM public.alembic_version');
SELECT pg_temp.expect_denied('SELECT set_config(''role'',''ll_migrator'',false)');
CREATE TEMP TABLE matter_number_counters(reference_year integer, last_value bigint) ON COMMIT DROP;
CREATE TEMP TABLE matter_number_allocations(id bigint, reference_year integer, sequence_value bigint, allocation_token uuid, allocated_at timestamptz) ON COMMIT DROP;
SELECT * FROM public.reserve_matter_number(2040,'d0000000-0000-0000-0000-000000000003');
SELECT * FROM public.reserve_matter_number(2040,'d0000000-0000-0000-0000-000000000003');
DO $$ BEGIN IF EXISTS (SELECT 1 FROM pg_temp.matter_number_counters) OR EXISTS (SELECT 1 FROM pg_temp.matter_number_allocations) THEN RAISE EXCEPTION 'Reservation used shadow tables'; END IF; END $$;
RESET SESSION AUTHORIZATION;
DO $$ BEGIN IF (SELECT count(*) FROM public.matter_number_allocations WHERE allocation_token='d0000000-0000-0000-0000-000000000003')<>1 THEN RAISE EXCEPTION 'Reservation retry not idempotent'; END IF; END $$;
ROLLBACK;
\echo 'Application role checks passed.'
