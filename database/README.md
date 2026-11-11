# PostgreSQL migrations and production gates

This is a **candidate migration baseline**, not approval to use real client data. It packages the sixteen reviewed-for-execution SQL drafts as frozen Alembic assets in `alembic/sql`, followed by an access revision. The current project has no SQLAlchemy model metadata; write migrations explicitly and do not use autogenerate as a source of truth. Do not edit a released revision or its SQL assets; add a new revision. No existing production database has been discovered or migrated.

## Disposable validation

From the repository root run `bash tests/database/run.sh` with Docker Compose. It builds the pinned Python migration dependencies, provisions temporary group roles, applies the baseline using Alembic, compares a schema-only dump to an independently constructed draft schema, applies the access revision, exercises downgrade safeguards and re-upgrade, and runs the SQL, concurrency, role, and foreign-key index checks. All data and the database container are disposable; no port is exposed. A Docker credential-helper failure for public images can be worked around by supplying an isolated Docker config if appropriate for your environment. `tests/database/README.md` gives details and coverage limits.

## Migration and role model

A database administrator provisions the NOLOGIN group roles from `bootstrap_roles.sql` and separately grants `ll_migrator` to the approved migration login and `ll_app` to a dedicated backend login. `ll_db_admin` may assume `ll_migrator` for controlled administration. Bootstrap needs role-creation and schema-ownership authority; test its compatibility with the chosen RDS administrator and review existing memberships before use. Never attach `ll_app` to a browser or other untrusted client.

The Alembic process receives an explicit `DATABASE_URL`; set `DB_MIGRATION_ROLE=ll_migrator` to assume the provisioned owner role. Verify the target, credentials, network access, backup and restore procedures before any non-test use. No passwords are stored in migration files. The migration owner owns the schema and functions. `ll_app` can read the draft tables and execute `reserve_matter_number`; it has **no business-data write privileges**. This is intentionally fail-closed until transactional service operations and their per-operation permissions have been reviewed and tested. Read grants do not provide matter isolation: an authenticated backend must enforce authorization on every read and write. Neither these roles nor the schema implement end-user identity, document access, legal approval, or row-level security.

The reservation function runs as the migration owner with a fixed search path; application callers cannot directly change its counter or allocations. The caller must persist a retry token and chosen firm-local year and commit reservation in its own transaction before exposing a reference or creating a matter. Membership, function ownership, public schema write access and grants must be inspected on the target; no production role configuration has been validated on RDS.

## Rollback and recovery

A baseline downgrade is intentionally unavailable by default. It requires `ALLOW_DISPOSABLE_DB_DOWNGRADE=1`, the exact database name `landholders_test`, and empty baseline tables; it is for an isolated test database only. Even then it uses `DROP ... CASCADE`, so do not enable the override on a database containing any other objects or meaningful data. The test suite exercises refusal with data and downgrade/re-upgrade on empty disposable tables. The access revision's downgrade changes grants and is likewise not an operational recovery plan.

For production, prefer a reviewed forward-fix migration; do not automatically downgrade destructive schema changes. Establish and exercise point-in-time RDS restore, independent S3 version/object recovery, retention and legal hold reconciliation, and recovery-time/data-loss objectives before launch. Rollbacks cannot undo external sends or S3 operations. Document and audit the operator, target, revision, outcome, and any recovery action.

## Open production blockers

- Reconcile the complete physical schema, constraints, partial indexes, natural keys, history and permissions with the evolving dictionary; the database-name inventory and catalog checks do not prove every business rule or source relationship is correct.
- Implement transactional service operations and tests for Workspace identity, matter access, activation, attorney authority, approval/exception materiality and revocation, sealed snapshot completeness, audit writes, and current-state/history synchronization.
- Decide and test narrow write grants or controlled database entrypoints for each operation. Audit events are protected only if the role model and transaction paths are correctly deployed; privileged database administrators can still alter them.
- Validate legal holds, retention and purge policy with the firm; implement and test S3 object-lock setup, independent multiple-hold reconciliation, scanning, notifications, failure alerts, and restore paths. Database rows do not prove external protection.
- Have the attorney and operations approve workflow templates, legal correspondence and closing/readiness rules; do not seed provisional examples as approved legal requirements.
- Test RDS role provisioning and TLS, representative-data query plans and volumes, broader isolation/race cases, invalid constraints, full backup restore, timezone/year boundary behavior, and lost COMMIT response recovery with the actual service. Record a deployment-specific security and operations review.
