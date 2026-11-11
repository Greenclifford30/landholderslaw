\set ON_ERROR_STOP on
DO $$ DECLARE seq record; BEGIN FOR seq IN SELECT schemaname,sequencename FROM pg_sequences WHERE schemaname='public' LOOP EXECUTE format('ALTER SEQUENCE %I.%I RESTART WITH 1',seq.schemaname,seq.sequencename); END LOOP; END $$;
BEGIN;
CREATE FUNCTION pg_temp.expect_error(statement text, expected_state text) RETURNS void LANGUAGE plpgsql AS $$ DECLARE actual_state text; BEGIN BEGIN EXECUTE statement; EXCEPTION WHEN OTHERS THEN GET STACKED DIAGNOSTICS actual_state=RETURNED_SQLSTATE; IF actual_state<>expected_state THEN RAISE EXCEPTION 'Expected %, got %: %',expected_state,actual_state,statement; END IF; RETURN; END; RAISE EXCEPTION 'Expected %, but succeeded: %',expected_state,statement; END $$;
INSERT INTO users(public_id,display_name,email) VALUES('60000000-0000-0000-0000-000000000001','Attorney','attorney@example.test');
INSERT INTO matter_number_allocations(reference_year,sequence_value,allocation_token) VALUES(2026,1,'60000000-0000-0000-0000-000000000002'),(2026,2,'60000000-0000-0000-0000-000000000003');
INSERT INTO matters(public_id,number_allocation_id,matter_type,created_by) VALUES('60000000-0000-0000-0000-000000000004',1,'buyer',1),('60000000-0000-0000-0000-000000000005',2,'buyer',1);
INSERT INTO correspondence(public_id,matter_id,title,status,created_by) VALUES('60000000-0000-0000-0000-000000000006',1,'Letter','draft',1);
INSERT INTO correspondence_drafts(matter_id,correspondence_id,revision,subject,body,delivery_method,created_by) VALUES(1,1,1,'Subject','Body','email',1);
INSERT INTO draft_recipients(matter_id,draft_id,recipient_kind,address,sort_order) VALUES(1,1,'to','recipient@example.test',1);
SELECT pg_temp.expect_error($q$INSERT INTO approval_requests(public_id,matter_id,draft_id,requested_by,status) VALUES('60000000-0000-0000-0000-000000000007',1,1,1,'pending')$q$,'P0001');
UPDATE correspondence_drafts SET sealed_at=now() WHERE id=1;
SELECT pg_temp.expect_error($q$INSERT INTO draft_recipients(matter_id,draft_id,recipient_kind,address,sort_order) VALUES(1,1,'cc','late@example.test',2)$q$,'P0001');
SELECT pg_temp.expect_error($q$UPDATE draft_recipients SET address='changed@example.test' WHERE draft_id=1$q$,'P0001');
INSERT INTO approval_requests(public_id,matter_id,draft_id,requested_by,status) VALUES('60000000-0000-0000-0000-000000000008',1,1,1,'pending');
INSERT INTO approval_decisions(matter_id,approval_request_id,decision,attorney_user_id) SELECT 1,id,'approved',1 FROM approval_requests;
SELECT pg_temp.expect_error($q$INSERT INTO correspondence_sends(matter_id,correspondence_id,entry_kind,method,entered_by) VALUES(1,1,'current','email',1)$q$,'23514');
INSERT INTO workflow_templates(code,name,matter_type) VALUES('buyer','Buyer','buyer');
INSERT INTO workflow_template_versions(workflow_template_id,version) VALUES(1,1);
UPDATE workflow_template_versions SET status='published',published_at=now() WHERE id=1;
INSERT INTO matter_workflows(matter_id,workflow_template_version_id,instantiated_by) VALUES(1,1,1);
INSERT INTO readiness_evaluations(matter_id,matter_workflow_id,workflow_template_version_id,result,purpose,evaluated_by) VALUES(1,1,1,'not_ready','review',1);
SELECT pg_temp.expect_error($q$INSERT INTO readiness_evaluation_items(matter_id,readiness_evaluation_id,finding_kind,outcome,description_snapshot) VALUES(1,1,'issue','blocking','Missing target')$q$,'23514');
INSERT INTO readiness_evaluation_items(matter_id,readiness_evaluation_id,finding_kind,outcome,description_snapshot) VALUES(1,1,'primary_attorney','blocking','No primary attorney');
SELECT pg_temp.expect_error($q$UPDATE readiness_evaluation_items SET description_snapshot='Changed'$q$,'P0001');
SELECT pg_temp.expect_error($q$INSERT INTO readiness_evaluation_item_sources(matter_id,readiness_evaluation_item_id) VALUES(1,2)$q$,'23514');
SELECT pg_temp.expect_error($q$INSERT INTO readiness_evaluations(matter_id,matter_workflow_id,workflow_template_version_id,result,purpose,evaluated_by) VALUES(2,1,1,'ready','review',1)$q$,'23503');
ROLLBACK;
\echo 'Correspondence and readiness checks passed.'
