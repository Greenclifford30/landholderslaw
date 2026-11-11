#!/usr/bin/env bash
set -euo pipefail
psql=(psql -X -q -v ON_ERROR_STOP=1 -U schema_test -d landholders_test)
wait_for() {
 local query=$1
 for _ in $(seq 1 150); do
  if [[ $("${psql[@]}" -Atc "$query") == t ]]; then return 0; fi
  sleep 0.1
 done
 echo 'Timed out waiting for database synchronization' >&2; return 1
}
# A backend terminated after making a reservation but before commit must roll it
# back, including the year counter. The token can then be safely retried.
PGAPPNAME=reservation_abort "${psql[@]}" >/tmp/reservation-abort.log 2>&1 <<'SQL' &
BEGIN;
SELECT * FROM reserve_matter_number(2032,'b0000000-0000-0000-0000-000000000001');
SELECT pg_advisory_xact_lock(719501);
SELECT pg_sleep(30);
COMMIT;
SQL
abort_pid=$!
wait_for "SELECT EXISTS (SELECT 1 FROM pg_locks WHERE locktype='advisory' AND objid=719501 AND granted)"
"${psql[@]}" -Atc "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE application_name='reservation_abort'" | grep -qx t
if wait "$abort_pid"; then echo 'Terminated uncommitted reservation unexpectedly succeeded' >&2; exit 1; fi
"${psql[@]}" -Atc "SELECT NOT EXISTS (SELECT 1 FROM matter_number_allocations WHERE allocation_token='b0000000-0000-0000-0000-000000000001') AND NOT EXISTS (SELECT 1 FROM matter_number_counters WHERE reference_year=2032)" | grep -qx t
"${psql[@]}" -Atc "SELECT reference_year=2032 AND sequence_value=1 FROM reserve_matter_number(2032,'b0000000-0000-0000-0000-000000000001')" | grep -qx t
# Terminate a backend only after COMMIT is complete but before the client has
# obtained its final response. This models a retry after a known server commit;
# it does not force a lost response at the COMMIT message itself.
PGAPPNAME=reservation_committed "${psql[@]}" >/tmp/reservation-committed.log 2>&1 <<'SQL' &
BEGIN;
SELECT * FROM reserve_matter_number(2033,'b0000000-0000-0000-0000-000000000002');
COMMIT;
SELECT pg_advisory_lock(719502);
SELECT pg_sleep(30);
SQL
committed_pid=$!
wait_for "SELECT EXISTS (SELECT 1 FROM pg_locks WHERE locktype='advisory' AND objid=719502 AND granted)"
"${psql[@]}" -Atc "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE application_name='reservation_committed'" | grep -qx t
if wait "$committed_pid"; then echo 'Terminated connection unexpectedly succeeded' >&2; exit 1; fi
"${psql[@]}" -Atc "SELECT reference_year=2033 AND sequence_value=1 FROM reserve_matter_number(2033,'b0000000-0000-0000-0000-000000000002')" | grep -qx t
# Same token at two different requested years: exactly one transaction wins.
"${psql[@]}" -Atc "SELECT * FROM reserve_matter_number(2034,'b0000000-0000-0000-0000-000000000003')" >/tmp/reservation-year-a.log 2>&1 & first=$!
"${psql[@]}" -Atc "SELECT * FROM reserve_matter_number(2035,'b0000000-0000-0000-0000-000000000003')" >/tmp/reservation-year-b.log 2>&1 & second=$!
a=0; b=0
wait "$first" || a=$?
wait "$second" || b=$?
if ! { [[ $a -eq 0 && $b -ne 0 ]] || [[ $a -ne 0 && $b -eq 0 ]]; }; then echo 'Cross-year race did not have exactly one winner' >&2; exit 1; fi
if [[ $a -ne 0 ]]; then failure=/tmp/reservation-year-a.log; else failure=/tmp/reservation-year-b.log; fi
if ! grep -q 'already bound to another year' "$failure"; then cat "$failure" >&2; exit 1; fi
"${psql[@]}" -Atc "SELECT count(*)=1 FROM matter_number_allocations WHERE allocation_token='b0000000-0000-0000-0000-000000000003'" | grep -qx t
# Separate year counters both start at one when independently reserved.
"${psql[@]}" -Atc "SELECT sequence_value=1 FROM reserve_matter_number(2036,'b0000000-0000-0000-0000-000000000004')" | grep -qx t
"${psql[@]}" -Atc "SELECT sequence_value=1 FROM reserve_matter_number(2037,'b0000000-0000-0000-0000-000000000005')" | grep -qx t
# Two writers competing for the same committed allocation cannot create two matters.
for n in 1 2; do
 "${psql[@]}" -c "INSERT INTO matters(public_id,number_allocation_id,created_by) SELECT ('b0000000-0000-0000-0001-00000000000$n')::uuid,a.id,u.id FROM matter_number_allocations a,users u WHERE a.allocation_token='b0000000-0000-0000-0000-000000000001' AND u.public_id='90000000-0000-0000-0000-000000000001'" >"/tmp/reservation-matter-$n.log" 2>&1 &
 if [[ $n == 1 ]]; then first=$!; else second=$!; fi
done
a=0; b=0
wait "$first" || a=$?
wait "$second" || b=$?
if ! { [[ $a -eq 0 && $b -ne 0 ]] || [[ $a -ne 0 && $b -eq 0 ]]; }; then echo 'Matter allocation race did not have exactly one winner' >&2; exit 1; fi
if [[ $a -ne 0 ]]; then failure=/tmp/reservation-matter-1.log; else failure=/tmp/reservation-matter-2.log; fi
if ! grep -q 'matters_number_allocation_id_key' "$failure"; then cat "$failure" >&2; exit 1; fi
"${psql[@]}" -Atc "SELECT count(*)=1 FROM matters m JOIN matter_number_allocations a ON a.id=m.number_allocation_id WHERE a.allocation_token='b0000000-0000-0000-0000-000000000001'" | grep -qx t
printf '%s\n' 'Reservation disconnect, year and matter-claim checks passed.'
