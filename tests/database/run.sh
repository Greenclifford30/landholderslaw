#!/usr/bin/env bash
set -euo pipefail
project="landholders-dbtest-$$-${RANDOM}"
compose=(docker compose -p "$project" -f "$(dirname "$0")/compose.yaml")
cleanup() { rm -f /tmp/"$project"-migrated.sql /tmp/"$project"-reference.sql /tmp/"$project"-downgrade.log; "${compose[@]}" down --remove-orphans >/dev/null; }
trap cleanup EXIT
python3 "$(dirname "$0")/dictionary_inventory.py"
"${compose[@]}" up -d --wait
# Provision group roles and grant this disposable cluster's test login the migration role.
"${compose[@]}" exec -T postgres psql -X -v ON_ERROR_STOP=1 -U schema_test -d landholders_test -f /database/bootstrap_roles.sql
"${compose[@]}" exec -T postgres psql -X -v ON_ERROR_STOP=1 -U schema_test -d landholders_test -c 'GRANT ll_migrator TO schema_test'
"${compose[@]}" run --rm migrations upgrade 0001_baseline
# Independently apply reference SQL to a second throwaway database and compare
# schema-only dumps before the separate role/grant revision.
"${compose[@]}" exec -T postgres createdb -U schema_test reference_test
"${compose[@]}" exec -T postgres psql -X -v ON_ERROR_STOP=1 -U schema_test -d reference_test -c "ALTER SCHEMA public OWNER TO ll_migrator"
for file in 001_foundation_draft.sql 002_matters_draft.sql 003_matter_snapshots_draft.sql 004_workflow_draft.sql 005_documents_deadlines_draft.sql 006_requirements_draft.sql 007_review_messaging_draft.sql 008_notifications_draft.sql 009_histories_draft.sql 010_contact_history_draft.sql 011_preservation_applicability_draft.sql 012_correspondence_draft.sql 013_readiness_draft.sql 014_readiness_integrity_draft.sql 015_approval_integrity_draft.sql 016_matter_reservation_draft.sql; do
  "${compose[@]}" exec -T postgres psql -X -q -v ON_ERROR_STOP=1 -U schema_test -d reference_test -f "/schema/$file"
done
"${compose[@]}" exec -T postgres pg_dump -U schema_test -s --no-owner --no-privileges -T public.alembic_version landholders_test | sed '/^\\restrict /d; /^\\unrestrict /d' > /tmp/"$project"-migrated.sql
"${compose[@]}" exec -T postgres pg_dump -U schema_test -s --no-owner --no-privileges -T public.alembic_version reference_test | sed '/^\\restrict /d; /^\\unrestrict /d' > /tmp/"$project"-reference.sql
if ! diff -u /tmp/"$project"-reference.sql /tmp/"$project"-migrated.sql; then
  echo 'Alembic baseline differs from reference DDL' >&2; exit 1
fi
rm -f /tmp/"$project"-migrated.sql /tmp/"$project"-reference.sql
"${compose[@]}" run --rm migrations upgrade head
# A baseline downgrade must refuse to destroy data, even in this disposable database.
"${compose[@]}" exec -T postgres psql -X -q -v ON_ERROR_STOP=1 -U schema_test -d landholders_test -c 'INSERT INTO firm_settings DEFAULT VALUES'
if "${compose[@]}" run --rm migrations downgrade base > /tmp/"$project"-downgrade.log 2>&1; then
  echo 'Baseline downgrade unexpectedly accepted nonempty tables' >&2; exit 1
fi
if ! grep -q 'contains data' /tmp/"$project"-downgrade.log; then cat /tmp/"$project"-downgrade.log >&2; exit 1; fi
rm -f /tmp/"$project"-downgrade.log
"${compose[@]}" exec -T postgres psql -X -q -v ON_ERROR_STOP=1 -U schema_test -d landholders_test -c 'DELETE FROM firm_settings'
"${compose[@]}" run --rm migrations upgrade head
# Only this empty ephemeral database permits the destructive baseline rollback.
"${compose[@]}" run --rm migrations downgrade 0001_baseline
"${compose[@]}" run --rm migrations downgrade base
"${compose[@]}" run --rm migrations upgrade head
"${compose[@]}" exec -T postgres psql -X -v ON_ERROR_STOP=1 -U schema_test -d landholders_test -f /tests/constraints.sql
"${compose[@]}" exec -T postgres psql -X -v ON_ERROR_STOP=1 -U schema_test -d landholders_test -f /tests/workflow.sql
"${compose[@]}" exec -T postgres psql -X -v ON_ERROR_STOP=1 -U schema_test -d landholders_test -f /tests/documents_deadlines.sql
"${compose[@]}" exec -T postgres psql -X -v ON_ERROR_STOP=1 -U schema_test -d landholders_test -f /tests/review.sql
"${compose[@]}" exec -T postgres psql -X -v ON_ERROR_STOP=1 -U schema_test -d landholders_test -f /tests/notifications.sql
"${compose[@]}" exec -T postgres psql -X -v ON_ERROR_STOP=1 -U schema_test -d landholders_test -f /tests/preservation.sql
"${compose[@]}" exec -T postgres psql -X -v ON_ERROR_STOP=1 -U schema_test -d landholders_test -f /tests/readiness_correspondence.sql
"${compose[@]}" exec -T postgres psql -X -v ON_ERROR_STOP=1 -U schema_test -d landholders_test -f /tests/readiness_integrity.sql
"${compose[@]}" exec -T postgres psql -X -v ON_ERROR_STOP=1 -U schema_test -d landholders_test -f /tests/approval_integrity.sql
"${compose[@]}" exec -T postgres bash /tests/concurrency.sh
"${compose[@]}" exec -T postgres psql -X -v ON_ERROR_STOP=1 -U schema_test -d landholders_test -f /tests/privileges.sql
"${compose[@]}" exec -T postgres bash /tests/reservation_concurrency.sh
"${compose[@]}" exec -T postgres bash /tests/reservation_recovery.sh
"${compose[@]}" exec -T postgres psql -X -v ON_ERROR_STOP=1 -U schema_test -d landholders_test -f /tests/access_roles.sql
"${compose[@]}" exec -T postgres psql -X -v ON_ERROR_STOP=1 -U schema_test -d landholders_test -f /tests/catalog_audit.sql
