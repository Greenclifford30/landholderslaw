\set ON_ERROR_STOP on
DO $$ DECLARE seq record; BEGIN FOR seq IN SELECT schemaname,sequencename FROM pg_sequences WHERE schemaname='public' LOOP EXECUTE format('ALTER SEQUENCE %I.%I RESTART WITH 1',seq.schemaname,seq.sequencename); END LOOP; END $$;
BEGIN;
CREATE FUNCTION pg_temp.expect_error(statement text, expected_state text) RETURNS void LANGUAGE plpgsql AS $$ DECLARE actual_state text; BEGIN BEGIN EXECUTE statement; EXCEPTION WHEN OTHERS THEN GET STACKED DIAGNOSTICS actual_state=RETURNED_SQLSTATE; IF actual_state<>expected_state THEN RAISE EXCEPTION 'Expected %, got %: %',expected_state,actual_state,statement; END IF; RETURN; END; RAISE EXCEPTION 'Expected %, but succeeded: %',expected_state,statement; END $$;
INSERT INTO users(public_id,display_name,email) VALUES('30000000-0000-0000-0000-000000000001','Staff','staff@example.test');
INSERT INTO matter_number_allocations(reference_year,sequence_value,allocation_token) VALUES(2026,1,'30000000-0000-0000-0000-000000000002'),(2026,2,'30000000-0000-0000-0000-000000000003');
INSERT INTO matters(public_id,number_allocation_id,created_by) VALUES('30000000-0000-0000-0000-000000000004',1,1),('30000000-0000-0000-0000-000000000005',2,1);
INSERT INTO correspondence(public_id,matter_id,title,status,created_by) VALUES('30000000-0000-0000-0000-000000000006',1,'Letter','draft',1);
INSERT INTO correspondence_drafts(matter_id,correspondence_id,revision,subject,body,delivery_method,created_by) VALUES(1,1,1,'Subject','Body','email',1);
SELECT pg_temp.expect_error($q$UPDATE correspondence_drafts SET body='Changed'$q$,'P0001');
UPDATE correspondence_drafts SET sealed_at=now() WHERE matter_id=1;
SELECT pg_temp.expect_error($q$INSERT INTO approval_requests(public_id,matter_id,requested_by,status) VALUES('30000000-0000-0000-0000-000000000007',1,1,'pending')$q$,'23514');
SELECT pg_temp.expect_error($q$INSERT INTO approval_requests(public_id,matter_id,draft_id,requested_by,status) VALUES('30000000-0000-0000-0000-000000000008',2,1,1,'pending')$q$,'23503');
INSERT INTO approval_requests(public_id,matter_id,draft_id,requested_by,status) VALUES('30000000-0000-0000-0000-000000000009',1,1,1,'pending');
SELECT pg_temp.expect_error($q$INSERT INTO approval_requests(public_id,matter_id,draft_id,requested_by,status) VALUES('30000000-0000-0000-0000-000000000010',1,1,1,'pending')$q$,'23505');
SELECT pg_temp.expect_error($q$INSERT INTO approval_decisions(matter_id,approval_request_id,decision,attorney_user_id) SELECT 1,id,'rejected',1 FROM approval_requests$q$,'23514');
INSERT INTO approval_decisions(matter_id,approval_request_id,decision,attorney_user_id) SELECT 1,id,'approved',1 FROM approval_requests;
SELECT pg_temp.expect_error($q$DELETE FROM approval_decisions$q$,'P0001');
INSERT INTO audit_events(actor_user_id,origin,action,entity_type) VALUES(1,'user','created','matter');
SELECT pg_temp.expect_error($q$DELETE FROM audit_events$q$,'P0001');
ROLLBACK;
\echo 'Review and audit checks passed.'
