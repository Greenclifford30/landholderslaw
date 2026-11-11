\set ON_ERROR_STOP on
DO $$ DECLARE seq record; BEGIN FOR seq IN SELECT schemaname,sequencename FROM pg_sequences WHERE schemaname='public' LOOP EXECUTE format('ALTER SEQUENCE %I.%I RESTART WITH 1',seq.schemaname,seq.sequencename); END LOOP; END $$;
BEGIN;
CREATE FUNCTION pg_temp.expect_error(statement text, expected_state text) RETURNS void LANGUAGE plpgsql AS $$
DECLARE actual_state text; BEGIN BEGIN EXECUTE statement; EXCEPTION WHEN OTHERS THEN GET STACKED DIAGNOSTICS actual_state = RETURNED_SQLSTATE; IF actual_state <> expected_state THEN RAISE EXCEPTION 'Expected %, got %: %',expected_state,actual_state,statement; END IF; RETURN; END; RAISE EXCEPTION 'Expected %, but succeeded: %',expected_state,statement; END $$;
INSERT INTO users(public_id,display_name,email) VALUES('20000000-0000-0000-0000-000000000001','Staff','staff@example.test');
INSERT INTO matter_number_allocations(reference_year,sequence_value,allocation_token) VALUES(2026,1,'20000000-0000-0000-0000-000000000002'),(2026,2,'20000000-0000-0000-0000-000000000003');
INSERT INTO matters(public_id,number_allocation_id,created_by) VALUES('20000000-0000-0000-0000-000000000004',1,1),('20000000-0000-0000-0000-000000000005',2,1);
INSERT INTO document_categories(code,label) VALUES('contract','Contract');
INSERT INTO deadline_types(code,label) VALUES('financing','Financing');
INSERT INTO documents(public_id,matter_id,document_category_id,title,created_by) VALUES('20000000-0000-0000-0000-000000000006',1,1,'Contract',1);
SELECT pg_temp.expect_error($q$INSERT INTO document_versions(public_id,matter_id,document_id,version_number,storage_kind,s3_bucket,s3_key,s3_version_id,external_url_ciphertext,external_url_key_reference,created_by) VALUES('20000000-0000-0000-0000-000000000007',1,1,1,'upload','bucket','key','version',decode('aa','hex'),'key',1)$q$,'23514');
INSERT INTO document_versions(public_id,matter_id,document_id,version_number,storage_kind,s3_bucket,s3_key,s3_version_id,created_by) VALUES('20000000-0000-0000-0000-000000000008',1,1,1,'upload','bucket','key','version',1);
SELECT pg_temp.expect_error($q$UPDATE document_versions SET s3_key='changed'$q$,'P0001');
INSERT INTO deadlines(public_id,matter_id,deadline_type_id,title,kind,status,due_on,created_by) VALUES('20000000-0000-0000-0000-000000000009',2,1,'Financing','contractual','open','2026-12-01',1);
SELECT pg_temp.expect_error($q$INSERT INTO deadline_revisions(matter_id,deadline_id,revision,deadline_type_id,due_on,timezone,source_document_version_id,reason,actor_user_id) VALUES(2,1,1,1,'2026-12-01','America/Chicago',2,'Initial',1)$q$,'23503');
INSERT INTO deadline_revisions(matter_id,deadline_id,revision,deadline_type_id,due_on,timezone,reason,actor_user_id) VALUES(2,1,1,1,'2026-12-01','America/Chicago','Initial',1);
SELECT pg_temp.expect_error($q$DELETE FROM deadline_revisions$q$,'P0001');
SELECT pg_temp.expect_error($q$INSERT INTO deadlines(public_id,matter_id,deadline_type_id,title,kind,status,due_on,due_time,created_by) VALUES('20000000-0000-0000-0000-000000000010',2,1,'Timed','contractual','open','2026-12-01','12:00',1)$q$,'23514');
SELECT pg_temp.expect_error($q$INSERT INTO matter_issues(public_id,matter_id,title,issue_type,status,severity) VALUES('20000000-0000-0000-0000-000000000011',2,'Issue','title','resolved','normal')$q$,'23514');

INSERT INTO matter_requirements(public_id,matter_id,title,kind,applicability,status,is_required,is_nonwaivable,created_by) VALUES('20000000-0000-0000-0000-000000000012',2,'Evidence','document','applicable','open',true,false,1);
SELECT pg_temp.expect_error($q$INSERT INTO requirement_evidence(matter_id,requirement_id,created_by) VALUES(2,1,1)$q$,'23514');
SELECT pg_temp.expect_error($q$INSERT INTO requirement_evidence(matter_id,requirement_id,document_version_id,created_by) VALUES(2,1,2,1)$q$,'23503');
INSERT INTO financial_confirmations(public_id,matter_id,kind,created_by) VALUES('20000000-0000-0000-0000-000000000013',2,'earnest_money',1);
INSERT INTO financial_confirmation_revisions(matter_id,financial_confirmation_id,revision,status,recorded_by) VALUES(2,1,1,'confirmed',1);
INSERT INTO requirement_evidence(matter_id,requirement_id,financial_confirmation_revision_id,created_by) VALUES(2,1,1,1);
SELECT pg_temp.expect_error($q$UPDATE financial_confirmation_revisions SET status='canceled'$q$,'P0001');
ROLLBACK;
\echo 'Document and deadline checks passed.'
