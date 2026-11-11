#!/usr/bin/env bash
set -euo pipefail
psql=(psql -X -q -v ON_ERROR_STOP=1 -U schema_test -d landholders_test)
# These fixtures are confined to this throwaway database.
"${psql[@]}" <<'SQL'
INSERT INTO users(public_id,display_name,email) VALUES('90000000-0000-0000-0000-000000000001','Race test','race@example.test');
INSERT INTO matter_number_allocations(reference_year,sequence_value,allocation_token) VALUES(2026,9001,'90000000-0000-0000-0000-000000000002');
INSERT INTO matters(public_id,number_allocation_id,created_by) SELECT '90000000-0000-0000-0000-000000000003',a.id,u.id FROM matter_number_allocations a,users u WHERE a.allocation_token='90000000-0000-0000-0000-000000000002' AND u.public_id='90000000-0000-0000-0000-000000000001';
INSERT INTO contacts(public_id,kind,display_name,created_by) SELECT '90000000-0000-0000-0000-000000000004','person','Race contact',id FROM users WHERE public_id='90000000-0000-0000-0000-000000000001';
INSERT INTO matter_parties(matter_id,contact_id) SELECT m.id,c.id FROM matters m,contacts c WHERE m.public_id='90000000-0000-0000-0000-000000000003' AND c.public_id='90000000-0000-0000-0000-000000000004';
INSERT INTO matter_party_snapshots(matter_id,matter_party_id,revision,display_name,recorded_by) SELECT mp.matter_id,mp.id,n,'Race snapshot',u.id FROM matter_parties mp JOIN matters m ON m.id=mp.matter_id CROSS JOIN users u CROSS JOIN generate_series(1,2) n WHERE m.public_id='90000000-0000-0000-0000-000000000003' AND u.public_id='90000000-0000-0000-0000-000000000001';
SQL
wait_for_sql() {
  local query=$1
  for _ in $(seq 1 100); do
    if [[ $("${psql[@]}" -Atc "$query") == t ]]; then return 0; fi
    sleep 0.1
  done
  echo 'Timed out waiting for the expected database lock' >&2
  return 1
}
# Locking side sleeps only after taking the relevant row lock. The other side is
# observed waiting on a PostgreSQL lock before the holder commits.
PGAPPNAME=race_sealer "${psql[@]}" > /tmp/race-sealer.log 2>&1 <<'SQL' &
BEGIN;
SET LOCAL statement_timeout='15s';
UPDATE matter_party_snapshots SET sealed_at=now() WHERE revision=1 AND display_name='Race snapshot';
SELECT pg_advisory_xact_lock(719401);
SELECT pg_sleep(4);
COMMIT;
SQL
sealer=$!
wait_for_sql "SELECT EXISTS (SELECT 1 FROM pg_locks WHERE locktype='advisory' AND objid=719401 AND granted)"
PGAPPNAME=race_late_child "${psql[@]}" > /tmp/race-late.log 2>&1 <<'SQL' &
SET statement_timeout='15s';
INSERT INTO matter_party_snapshot_methods(snapshot_id,kind,value) SELECT id,'email','late@example.test' FROM matter_party_snapshots WHERE revision=1 AND display_name='Race snapshot';
SQL
late=$!
wait_for_sql "SELECT EXISTS (SELECT 1 FROM pg_stat_activity WHERE application_name='race_late_child' AND wait_event_type='Lock')"
wait "$sealer"
if wait "$late"; then echo 'Late child unexpectedly inserted' >&2; exit 1; fi
if ! grep -q 'cannot add children to a sealed snapshot' /tmp/race-late.log; then cat /tmp/race-late.log >&2; exit 1; fi
# Reverse the order: the child holds the parent lock, then sealing waits. The
# committed child must remain part of the sealed snapshot.
PGAPPNAME=race_child_first "${psql[@]}" > /tmp/race-child.log 2>&1 <<'SQL' &
BEGIN;
SET LOCAL statement_timeout='15s';
INSERT INTO matter_party_snapshot_methods(snapshot_id,kind,value) SELECT id,'email','first@example.test' FROM matter_party_snapshots WHERE revision=2 AND display_name='Race snapshot';
SELECT pg_advisory_xact_lock(719402);
SELECT pg_sleep(4);
COMMIT;
SQL
child=$!
wait_for_sql "SELECT EXISTS (SELECT 1 FROM pg_locks WHERE locktype='advisory' AND objid=719402 AND granted)"
PGAPPNAME=race_seal_second "${psql[@]}" > /tmp/race-seal-second.log 2>&1 <<'SQL' &
SET statement_timeout='15s';
UPDATE matter_party_snapshots SET sealed_at=now() WHERE revision=2 AND display_name='Race snapshot';
SQL
seal_second=$!
wait_for_sql "SELECT EXISTS (SELECT 1 FROM pg_stat_activity WHERE application_name='race_seal_second' AND wait_event_type='Lock')"
wait "$child"
wait "$seal_second"
"${psql[@]}" -Atc "SELECT CASE WHEN count(*)=1 AND bool_and(s.sealed_at IS NOT NULL) THEN 'ok' ELSE 'bad' END FROM matter_party_snapshots s JOIN matter_party_snapshot_methods m ON m.snapshot_id=s.id WHERE s.revision=2 AND s.display_name='Race snapshot' AND m.value='first@example.test'" | grep -qx ok
printf '%s\n' 'Two-session snapshot sealing checks passed.'
"${psql[@]}" <<'SQL'
INSERT INTO workflow_templates(code,name,matter_type) VALUES('RACE_TEST','Race test','buyer');
INSERT INTO workflow_template_versions(workflow_template_id,version) SELECT id,1 FROM workflow_templates WHERE code='RACE_TEST';
SQL
PGAPPNAME=race_publish "${psql[@]}" > /tmp/race-publish.log 2>&1 <<'SQL' &
BEGIN;
SET LOCAL statement_timeout='15s';
UPDATE workflow_template_versions SET status='published',published_at=now() WHERE workflow_template_id=(SELECT id FROM workflow_templates WHERE code='RACE_TEST');
SELECT pg_advisory_xact_lock(719403);
SELECT pg_sleep(4);
COMMIT;
SQL
publisher=$!
wait_for_sql "SELECT EXISTS (SELECT 1 FROM pg_locks WHERE locktype='advisory' AND objid=719403 AND granted)"
PGAPPNAME=race_workflow_edit "${psql[@]}" > /tmp/race-workflow-edit.log 2>&1 <<'SQL' &
SET statement_timeout='15s';
INSERT INTO workflow_phases(workflow_template_version_id,phase_key,name,sort_order) SELECT id,'late','Late',1 FROM workflow_template_versions WHERE workflow_template_id=(SELECT id FROM workflow_templates WHERE code='RACE_TEST');
SQL
editor=$!
wait_for_sql "SELECT EXISTS (SELECT 1 FROM pg_stat_activity WHERE application_name='race_workflow_edit' AND wait_event_type='Lock')"
wait "$publisher"
if wait "$editor"; then echo 'Published workflow unexpectedly accepted a late edit' >&2; exit 1; fi
if ! grep -q 'published workflow definitions are immutable' /tmp/race-workflow-edit.log; then cat /tmp/race-workflow-edit.log >&2; exit 1; fi
printf '%s\n' 'Two-session workflow publication check passed.'
# Readiness and send aggregates cannot commit unsealed. A second session cannot
# see an in-flight parent, and after commit it must observe the sealed parent.
"${psql[@]}" <<'SQL'
UPDATE matters SET matter_type='buyer' WHERE public_id='90000000-0000-0000-0000-000000000003';
INSERT INTO matter_workflows(matter_id,workflow_template_version_id,instantiated_by)
SELECT m.id,v.id,u.id FROM matters m,workflow_template_versions v JOIN workflow_templates t ON t.id=v.workflow_template_id,users u
WHERE m.public_id='90000000-0000-0000-0000-000000000003' AND t.code='RACE_TEST' AND u.public_id='90000000-0000-0000-0000-000000000001';
INSERT INTO correspondence(public_id,matter_id,title,status,created_by)
SELECT '90000000-0000-0000-0000-000000000005',m.id,'Race letter','draft',u.id FROM matters m,users u
WHERE m.public_id='90000000-0000-0000-0000-000000000003' AND u.public_id='90000000-0000-0000-0000-000000000001';
SQL
PGAPPNAME=race_readiness_writer "${psql[@]}" > /tmp/race-readiness.log 2>&1 <<'SQL' &
BEGIN;
SET LOCAL statement_timeout='15s';
INSERT INTO readiness_evaluations(id,matter_id,matter_workflow_id,workflow_template_version_id,result,purpose,evaluated_by) OVERRIDING SYSTEM VALUE
SELECT 910001,mw.matter_id,mw.id,mw.workflow_template_version_id,'not_ready','review',mw.instantiated_by FROM matter_workflows mw JOIN matters m ON m.id=mw.matter_id WHERE m.public_id='90000000-0000-0000-0000-000000000003';
UPDATE readiness_evaluations SET sealed_at=now() WHERE id=910001;
SELECT pg_advisory_xact_lock(719404);
SELECT pg_sleep(4);
COMMIT;
SQL
readiness_writer=$!
wait_for_sql "SELECT EXISTS (SELECT 1 FROM pg_locks WHERE locktype='advisory' AND objid=719404 AND granted)"
if "${psql[@]}" > /tmp/race-readiness-child.log 2>&1 <<'SQL'
INSERT INTO readiness_evaluation_items(matter_id,readiness_evaluation_id,finding_kind,outcome,description_snapshot)
SELECT id,910001,'primary_attorney','blocking','Concurrent insert' FROM matters WHERE public_id='90000000-0000-0000-0000-000000000003';
SQL
then echo 'A child unexpectedly saw an uncommitted readiness evaluation' >&2; exit 1; fi
if ! grep -q 'readiness evaluation missing' /tmp/race-readiness-child.log; then cat /tmp/race-readiness-child.log >&2; exit 1; fi
wait "$readiness_writer"
if "${psql[@]}" > /tmp/race-readiness-late.log 2>&1 <<'SQL'
INSERT INTO readiness_evaluation_items(matter_id,readiness_evaluation_id,finding_kind,outcome,description_snapshot)
SELECT id,910001,'primary_attorney','blocking','Late insert' FROM matters WHERE public_id='90000000-0000-0000-0000-000000000003';
SQL
then echo 'A late readiness item unexpectedly succeeded' >&2; exit 1; fi
if ! grep -q 'readiness evaluation is sealed' /tmp/race-readiness-late.log; then cat /tmp/race-readiness-late.log >&2; exit 1; fi
PGAPPNAME=race_send_writer "${psql[@]}" > /tmp/race-send.log 2>&1 <<'SQL' &
BEGIN;
SET LOCAL statement_timeout='15s';
INSERT INTO correspondence_sends(id,matter_id,correspondence_id,entry_kind,sent_on,cutoff_on,method,entered_by) OVERRIDING SYSTEM VALUE
SELECT 910001,c.matter_id,c.id,'historical','2026-01-01','2026-11-01','email',c.created_by FROM correspondence c WHERE c.public_id='90000000-0000-0000-0000-000000000005';
UPDATE correspondence_sends SET sealed_at=now() WHERE id=910001;
SELECT pg_advisory_xact_lock(719405);
SELECT pg_sleep(4);
COMMIT;
SQL
send_writer=$!
wait_for_sql "SELECT EXISTS (SELECT 1 FROM pg_locks WHERE locktype='advisory' AND objid=719405 AND granted)"
if "${psql[@]}" > /tmp/race-send-child.log 2>&1 <<'SQL'
INSERT INTO correspondence_send_recipients(matter_id,send_id,recipient_kind,address)
SELECT id,910001,'to','concurrent@example.test' FROM matters WHERE public_id='90000000-0000-0000-0000-000000000003';
SQL
then echo 'A child unexpectedly saw an uncommitted send' >&2; exit 1; fi
if ! grep -q 'send missing' /tmp/race-send-child.log; then cat /tmp/race-send-child.log >&2; exit 1; fi
wait "$send_writer"
if "${psql[@]}" > /tmp/race-send-late.log 2>&1 <<'SQL'
INSERT INTO correspondence_send_recipients(matter_id,send_id,recipient_kind,address)
SELECT id,910001,'to','late@example.test' FROM matters WHERE public_id='90000000-0000-0000-0000-000000000003';
SQL
then echo 'A late send recipient unexpectedly succeeded' >&2; exit 1; fi
if ! grep -q 'send is sealed' /tmp/race-send-late.log; then cat /tmp/race-send-late.log >&2; exit 1; fi
printf '%s\n' 'Two-session readiness and send visibility and sealing checks passed.'
