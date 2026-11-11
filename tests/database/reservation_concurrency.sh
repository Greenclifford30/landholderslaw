#!/usr/bin/env bash
set -euo pipefail
psql=(psql -X -q -v ON_ERROR_STOP=1 -U schema_test -d landholders_test)
pids=()
for n in $(seq 1 8); do
  "${psql[@]}" -Atc "SELECT allocation_id,reference_year,sequence_value FROM reserve_matter_number(2030,'a0000000-0000-0000-0000-000000000001')" > "/tmp/reservation-same-$n" &
  pids+=("$!")
done
for pid in "${pids[@]}"; do wait "$pid"; done
if [[ $(cat /tmp/reservation-same-{1..8} | sort -u | wc -l) -ne 1 ]]; then echo 'Retries with one token returned different allocations' >&2; exit 1; fi
pids=()
for n in $(seq 1 8); do
  token=$(printf 'a0000000-0000-0000-0000-%012d' "$((n+1))")
  "${psql[@]}" -Atc "SELECT allocation_id,reference_year,sequence_value FROM reserve_matter_number(2030,'$token')" > "/tmp/reservation-distinct-$n" &
  pids+=("$!")
done
for pid in "${pids[@]}"; do wait "$pid"; done
if [[ $(cat /tmp/reservation-distinct-{1..8} | cut -d '|' -f 3 | sort -u | wc -l) -ne 8 ]]; then echo 'Distinct tokens received duplicate sequences' >&2; exit 1; fi
if "${psql[@]}" -c "SELECT * FROM reserve_matter_number(2031,'a0000000-0000-0000-0000-000000000001')" >/tmp/reservation-wrong-year 2>&1; then echo 'Cross-year retry unexpectedly succeeded' >&2; exit 1; fi
if ! grep -q 'already bound to another year' /tmp/reservation-wrong-year; then cat /tmp/reservation-wrong-year >&2; exit 1; fi
# Reservation committed in its own psql connection. A later failed matter
# transaction must not remove it or make its number available to another token.
"${psql[@]}" -c "BEGIN; INSERT INTO matters(public_id,number_allocation_id,created_by) SELECT 'a0000000-0000-0000-0000-000000000099',id,999999 FROM matter_number_allocations WHERE allocation_token='a0000000-0000-0000-0000-000000000001'; COMMIT;" >/tmp/reservation-failed-matter 2>&1 && { echo 'Invalid matter unexpectedly succeeded' >&2; exit 1; }
if ! grep -q 'foreign key constraint' /tmp/reservation-failed-matter; then cat /tmp/reservation-failed-matter >&2; exit 1; fi
"${psql[@]}" -Atc "SELECT count(*)=1 FROM matter_number_allocations WHERE allocation_token='a0000000-0000-0000-0000-000000000001' AND reference_year=2030 AND sequence_value=1" | grep -qx t
"${psql[@]}" -Atc "SELECT last_value=9 FROM matter_number_counters WHERE reference_year=2030" | grep -qx t
printf '%s\n' 'Concurrent allocation retry and rollback checks passed.'
