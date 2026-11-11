\set ON_ERROR_STOP on
DO $$ DECLARE seq record; BEGIN FOR seq IN SELECT schemaname,sequencename FROM pg_sequences WHERE schemaname='public' LOOP EXECUTE format('ALTER SEQUENCE %I.%I RESTART WITH 1',seq.schemaname,seq.sequencename); END LOOP; END $$;
BEGIN;
CREATE FUNCTION pg_temp.expect_error(statement text, expected_state text) RETURNS void LANGUAGE plpgsql AS $$ DECLARE actual_state text; BEGIN BEGIN EXECUTE statement; EXCEPTION WHEN OTHERS THEN GET STACKED DIAGNOSTICS actual_state=RETURNED_SQLSTATE; IF actual_state<>expected_state THEN RAISE EXCEPTION 'Expected %, got %: %',expected_state,actual_state,statement; END IF; RETURN; END; RAISE EXCEPTION 'Expected %, but succeeded: %',expected_state,statement; END $$;
INSERT INTO users(public_id,display_name,email) VALUES('50000000-0000-0000-0000-000000000001','Staff','staff@example.test');
INSERT INTO matter_number_allocations(reference_year,sequence_value,allocation_token) VALUES(2026,1,'50000000-0000-0000-0000-000000000002'),(2026,2,'50000000-0000-0000-0000-000000000003');
INSERT INTO matters(public_id,number_allocation_id,created_by) VALUES('50000000-0000-0000-0000-000000000004',1,1),('50000000-0000-0000-0000-000000000005',2,1);
INSERT INTO matter_legal_holds(public_id,matter_id,reason,placed_by) VALUES('50000000-0000-0000-0000-000000000006',1,'Preserve records',1);
SELECT pg_temp.expect_error($q$UPDATE matter_legal_holds SET status='released',released_by=1,released_at=now() WHERE matter_id=1$q$,'23514');
UPDATE matter_legal_holds SET status='released',released_by=1,released_at=now(),release_reason='Resolved' WHERE matter_id=1;
INSERT INTO tasks(public_id,matter_id,source,title,is_required,created_by) VALUES('50000000-0000-0000-0000-000000000007',1,'manual','Review',true,1);
INSERT INTO matter_requirements(public_id,matter_id,title,kind,applicability,status,is_required,is_nonwaivable,created_by) VALUES('50000000-0000-0000-0000-000000000008',2,'Evidence','document','applicable','open',true,false,1);
SELECT pg_temp.expect_error($q$INSERT INTO applicability_overrides(matter_id,task_id,requirement_id,decision,reason,actor_user_id) VALUES(1,1,1,'applicable','reason',1)$q$,'23514');
SELECT pg_temp.expect_error($q$INSERT INTO applicability_overrides(matter_id,requirement_id,decision,reason,actor_user_id) VALUES(1,1,'applicable','reason',1)$q$,'23503');
INSERT INTO applicability_overrides(matter_id,task_id,decision,reason,actor_user_id) VALUES(1,1,'applicable','Reviewed',1);
SELECT pg_temp.expect_error($q$UPDATE applicability_overrides SET reason='Changed'$q$,'P0001');
SELECT pg_temp.expect_error($q$INSERT INTO closing_milestone_links(matter_id,offset_days) VALUES(1,-2)$q$,'23514');
INSERT INTO closing_milestone_links(matter_id,task_id,offset_days) VALUES(1,1,-2);
ROLLBACK;
\echo 'Preservation and applicability checks passed.'
