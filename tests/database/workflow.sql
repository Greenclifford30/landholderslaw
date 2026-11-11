\set ON_ERROR_STOP on
-- Prior rolled-back tests still advance PostgreSQL sequences. This disposable database is empty.
DO $$
DECLARE seq record;
BEGIN
    FOR seq IN SELECT schemaname, sequencename FROM pg_sequences WHERE schemaname = 'public' LOOP
        EXECUTE format('ALTER SEQUENCE %I.%I RESTART WITH 1', seq.schemaname, seq.sequencename);
    END LOOP;
END;
$$;
BEGIN;
CREATE FUNCTION pg_temp.expect_error(statement text, expected_state text) RETURNS void LANGUAGE plpgsql AS $$
DECLARE actual_state text;
BEGIN
    BEGIN EXECUTE statement;
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS actual_state = RETURNED_SQLSTATE;
        IF actual_state <> expected_state THEN RAISE EXCEPTION 'Expected %, got %: %', expected_state, actual_state, statement; END IF;
        RETURN;
    END;
    RAISE EXCEPTION 'Expected %, but succeeded: %', expected_state, statement;
END;
$$;
INSERT INTO users (public_id,display_name,email) VALUES ('10000000-0000-0000-0000-000000000001','Staff','staff@example.test');
INSERT INTO matter_number_allocations (reference_year,sequence_value,allocation_token) VALUES (2026,1,'10000000-0000-0000-0000-000000000002'),(2026,2,'10000000-0000-0000-0000-000000000003');
INSERT INTO matters (public_id,number_allocation_id,matter_type,created_by) VALUES ('10000000-0000-0000-0000-000000000004',1,'buyer',1),('10000000-0000-0000-0000-000000000005',2,'seller',1);
INSERT INTO workflow_templates (code,name,matter_type) VALUES ('buyer','Buyer','buyer');
SELECT pg_temp.expect_error($q$INSERT INTO workflow_template_versions (workflow_template_id,version,status,published_at) VALUES (1,9,'published',now())$q$,'P0001');
ALTER SEQUENCE workflow_template_versions_id_seq RESTART WITH 1;
INSERT INTO workflow_template_versions (workflow_template_id,version) VALUES (1,1),(1,2);
INSERT INTO workflow_phases (workflow_template_version_id,phase_key,name,sort_order) VALUES (1,'initial','Initial',1);
SELECT pg_temp.expect_error($q$INSERT INTO workflow_task_templates (workflow_template_version_id,workflow_phase_id,task_key,title,sort_order) VALUES (2,1,'bad','Bad',1)$q$,'23503');
INSERT INTO workflow_task_templates (workflow_template_version_id,workflow_phase_id,task_key,title,sort_order) VALUES (1,1,'review','Review',1);
SELECT pg_temp.expect_error($q$INSERT INTO matter_workflows (matter_id,workflow_template_version_id,instantiated_by) VALUES (1,1,1)$q$,'P0001');
UPDATE workflow_template_versions SET status='published',published_at=now() WHERE id=1;
SELECT pg_temp.expect_error($q$UPDATE workflow_phases SET name='Changed' WHERE id=1$q$,'P0001');
SELECT pg_temp.expect_error($q$INSERT INTO workflow_phases (workflow_template_version_id,phase_key,name,sort_order) VALUES (1,'late','Late',2)$q$,'P0001');
SELECT pg_temp.expect_error($q$INSERT INTO matter_workflows (matter_id,workflow_template_version_id,instantiated_by) VALUES (2,1,1)$q$,'P0001');
INSERT INTO matter_workflows (matter_id,workflow_template_version_id,instantiated_by) VALUES (1,1,1);
SELECT pg_temp.expect_error($q$UPDATE matters SET matter_type='seller' WHERE id=1$q$,'P0001');
INSERT INTO tasks (public_id,matter_id,matter_workflow_id,workflow_template_version_id,workflow_task_template_id,source,title,is_required,created_by) VALUES ('10000000-0000-0000-0000-000000000006',1,(SELECT id FROM matter_workflows WHERE matter_id=1),1,2,'standard','Review',true,1);
SELECT pg_temp.expect_error($q$UPDATE tasks SET matter_id=2 WHERE public_id='10000000-0000-0000-0000-000000000006'$q$,'23503');
SELECT pg_temp.expect_error($q$INSERT INTO tasks (public_id,matter_id,source,title,is_required,created_by,due_time) VALUES ('10000000-0000-0000-0000-000000000008',1,'manual','Incomplete timed task',false,1,'10:00')$q$,'23514');
SELECT pg_temp.expect_error($q$INSERT INTO task_dependencies (matter_id,task_id,depends_on_task_id) VALUES (1,1,1)$q$,'23514');
UPDATE workflow_template_versions SET status='retired' WHERE id=1;
SELECT pg_temp.expect_error($q$UPDATE workflow_template_versions SET status='published' WHERE id=1$q$,'P0001');
ROLLBACK;
\echo 'Workflow schema checks passed.'
