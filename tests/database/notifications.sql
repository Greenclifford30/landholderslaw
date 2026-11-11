\set ON_ERROR_STOP on
DO $$ DECLARE seq record; BEGIN FOR seq IN SELECT schemaname,sequencename FROM pg_sequences WHERE schemaname='public' LOOP EXECUTE format('ALTER SEQUENCE %I.%I RESTART WITH 1',seq.schemaname,seq.sequencename); END LOOP; END $$;
BEGIN;
CREATE FUNCTION pg_temp.expect_error(statement text, expected_state text) RETURNS void LANGUAGE plpgsql AS $$ DECLARE actual_state text; BEGIN BEGIN EXECUTE statement; EXCEPTION WHEN OTHERS THEN GET STACKED DIAGNOSTICS actual_state=RETURNED_SQLSTATE; IF actual_state<>expected_state THEN RAISE EXCEPTION 'Expected %, got %: %',expected_state,actual_state,statement; END IF; RETURN; END; RAISE EXCEPTION 'Expected %, but succeeded: %',expected_state,statement; END $$;
INSERT INTO users(public_id,display_name,email) VALUES('40000000-0000-0000-0000-000000000001','Staff','staff@example.test');
INSERT INTO matter_number_allocations(reference_year,sequence_value,allocation_token) VALUES(2026,1,'40000000-0000-0000-0000-000000000002'),(2026,2,'40000000-0000-0000-0000-000000000003');
INSERT INTO matters(public_id,number_allocation_id,created_by) VALUES('40000000-0000-0000-0000-000000000004',1,1),('40000000-0000-0000-0000-000000000005',2,1);
INSERT INTO deadline_types(code,label) VALUES('financing','Financing');
INSERT INTO deadlines(public_id,matter_id,deadline_type_id,title,kind,status,due_on,created_by) VALUES('40000000-0000-0000-0000-000000000006',1,1,'First','contractual','open','2026-12-01',1),('40000000-0000-0000-0000-000000000007',2,1,'Second','contractual','open','2026-12-02',1);
INSERT INTO deadline_revisions(matter_id,deadline_id,revision,deadline_type_id,due_on,timezone,reason,actor_user_id) VALUES(1,1,1,1,'2026-12-01','America/Chicago','Initial',1),(2,2,1,1,'2026-12-02','America/Chicago','Initial',1);
SELECT pg_temp.expect_error($q$INSERT INTO reminder_occurrences(matter_id,deadline_id,deadline_revision_id,recipient_user_id,channel,local_on,scheduled_at,status) VALUES(1,1,2,1,'email','2026-12-01',now(),'queued')$q$,'23503');
INSERT INTO reminder_occurrences(matter_id,deadline_id,deadline_revision_id,recipient_user_id,channel,local_on,scheduled_at,status) VALUES(1,1,1,1,'email','2026-12-01',now(),'queued');
SELECT pg_temp.expect_error($q$INSERT INTO reminder_occurrences(matter_id,deadline_id,deadline_revision_id,recipient_user_id,channel,local_on,scheduled_at,status) VALUES(1,1,1,1,'email','2026-12-01',now(),'queued')$q$,'23505');
INSERT INTO reminder_occurrence_reasons(reminder_occurrence_id,kind) SELECT id,'overdue' FROM reminder_occurrences;
SELECT pg_temp.expect_error($q$INSERT INTO reminder_occurrence_reasons(reminder_occurrence_id,kind) SELECT id,'overdue' FROM reminder_occurrences$q$,'23505');
SELECT pg_temp.expect_error($q$INSERT INTO reminder_occurrence_reasons(reminder_occurrence_id,kind) SELECT id,'advance' FROM reminder_occurrences$q$,'23514');
SELECT pg_temp.expect_error($q$INSERT INTO notifications(public_id,matter_id,recipient_user_id,reminder_occurrence_id,kind) SELECT '40000000-0000-0000-0000-000000000008',2,1,id,'deadline' FROM reminder_occurrences$q$,'23503');
ROLLBACK;
\echo 'Notification checks passed.'
