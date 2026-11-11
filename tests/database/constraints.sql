\set ON_ERROR_STOP on
BEGIN;
CREATE FUNCTION pg_temp.expect_error(statement text, expected_state text) RETURNS void
LANGUAGE plpgsql AS $$
DECLARE actual_state text;
BEGIN
    BEGIN EXECUTE statement;
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS actual_state = RETURNED_SQLSTATE;
        IF actual_state <> expected_state THEN
            RAISE EXCEPTION 'Expected SQLSTATE %, got % for: %', expected_state, actual_state, statement;
        END IF;
        RETURN;
    END;
    RAISE EXCEPTION 'Expected SQLSTATE %, but statement succeeded: %', expected_state, statement;
END;
$$;
INSERT INTO users (public_id, display_name, email, role) VALUES
 ('00000000-0000-0000-0000-000000000001', 'Attorney', 'attorney@example.test', 'attorney'),
 ('00000000-0000-0000-0000-000000000002', 'Staff', 'staff@example.test', 'operations');
INSERT INTO user_identities (user_id, provider, issuer, subject) VALUES (1, 'sandbox', 'test', 'identity-1');
UPDATE user_identities SET last_verified_at = now() WHERE id = 1;
SELECT pg_temp.expect_error($q$UPDATE user_identities SET user_id = 2 WHERE id = 1$q$, 'P0001');
SELECT pg_temp.expect_error($q$DELETE FROM user_identities WHERE id = 1$q$, 'P0001');
SELECT pg_temp.expect_error($q$INSERT INTO user_identities (user_id, provider, issuer, subject) VALUES (2, 'sandbox', 'test', 'identity-1')$q$, '23505');
INSERT INTO contacts (public_id, kind, display_name, created_by) VALUES
 ('00000000-0000-0000-0000-000000000011', 'person', 'Client One', 1),
 ('00000000-0000-0000-0000-000000000012', 'person', 'Client Two', 1);
SELECT pg_temp.expect_error($q$INSERT INTO contacts (public_id, kind, display_name, created_by) VALUES ('00000000-0000-0000-0000-000000000013', 'organization', 'No Name', 1)$q$, '23514');
INSERT INTO contact_methods (contact_id, kind, value, is_preferred) VALUES (1, 'email', 'one@example.test', true);
SELECT pg_temp.expect_error($q$INSERT INTO contact_methods (contact_id, kind, value, is_preferred) VALUES (1, 'email', 'two@example.test', true)$q$, '23505');
SELECT pg_temp.expect_error($q$INSERT INTO contact_methods (contact_id, kind, value) VALUES (999, 'email', 'x@example.test')$q$, '23503');
INSERT INTO properties (public_id, address_line1, city) VALUES ('00000000-0000-0000-0000-000000000021', '1 Example Street', 'Chicago');
SELECT pg_temp.expect_error($q$INSERT INTO properties (public_id, address_line1, city, state) VALUES ('00000000-0000-0000-0000-000000000022', '1 Example', 'Chicago', 'WI')$q$, '23514');
INSERT INTO matter_number_allocations (reference_year, sequence_value, allocation_token) VALUES
 (2026, 1, '00000000-0000-0000-0000-000000000031'), (2026, 2, '00000000-0000-0000-0000-000000000032');
INSERT INTO matters (public_id, number_allocation_id, created_by) VALUES
 ('00000000-0000-0000-0000-000000000041', 1, 1), ('00000000-0000-0000-0000-000000000042', 2, 1);
SELECT pg_temp.expect_error($q$INSERT INTO matters (public_id, number_allocation_id, created_by) VALUES ('00000000-0000-0000-0000-000000000043', 1, 1)$q$, '23505');
SELECT pg_temp.expect_error($q$UPDATE matters SET number_allocation_id = 2 WHERE id = 1$q$, 'P0001');
SELECT pg_temp.expect_error($q$UPDATE matter_number_allocations SET sequence_value = 10 WHERE id = 1$q$, 'P0001');
INSERT INTO matter_parties (matter_id, contact_id, is_client, is_primary_client) VALUES (1, 1, true, true);
SELECT pg_temp.expect_error($q$INSERT INTO matter_parties (matter_id, contact_id, is_client, is_primary_client) VALUES (1, 2, true, true)$q$, '23505');
SELECT pg_temp.expect_error($q$UPDATE matter_parties SET matter_id = 2 WHERE id = 1$q$, 'P0001');
INSERT INTO matter_properties (matter_id, property_id, is_primary) VALUES (1, 1, true);
INSERT INTO matter_assignments (matter_id, user_id, assignment_role, is_primary, assigned_by) VALUES (1, 1, 'attorney', true, 1);
UPDATE matter_assignments SET ended_at = now() WHERE id = 1;
SELECT pg_temp.expect_error($q$UPDATE matter_assignments SET ended_at = NULL WHERE id = 1$q$, 'P0001');
INSERT INTO matter_access_grants (matter_id, user_id, granted_by) VALUES (1, 2, 1);
UPDATE matter_access_grants SET revoked_at = now(), revoked_by = 1 WHERE id = 1;
SELECT pg_temp.expect_error($q$UPDATE matter_access_grants SET revoked_at = NULL, revoked_by = NULL WHERE id = 1$q$, 'P0001');
INSERT INTO matter_lifecycle_events (matter_id, event_type, actor_user_id) VALUES (1, 'activated', 1);
SELECT pg_temp.expect_error($q$DELETE FROM matter_lifecycle_events WHERE id = 1$q$, 'P0001');
SELECT pg_temp.expect_error($q$INSERT INTO matter_lifecycle_events (matter_id, event_type, actor_user_id) VALUES (1, 'file_closed', 1)$q$, '23514');
SELECT pg_temp.expect_error($q$INSERT INTO matter_party_snapshots (matter_id, matter_party_id, revision, display_name, recorded_by) VALUES (2, 1, 1, 'Wrong matter', 1)$q$, '23503');
INSERT INTO matter_party_snapshots (matter_id, matter_party_id, revision, display_name, recorded_by) VALUES (1, 1, 1, 'Client One', 1);
INSERT INTO matter_party_snapshot_methods (snapshot_id, kind, value, is_preferred) VALUES (2, 'email', 'one@example.test', true);
UPDATE matter_party_snapshots SET sealed_at = now() WHERE matter_party_id = 1;
SELECT pg_temp.expect_error($q$INSERT INTO matter_party_snapshot_methods (snapshot_id, kind, value) VALUES (2, 'phone', '555-0100')$q$, 'P0001');
SELECT pg_temp.expect_error($q$UPDATE matter_party_snapshots SET display_name = 'Changed' WHERE matter_party_id = 1$q$, 'P0001');
INSERT INTO matter_property_snapshots (matter_id, matter_property_id, revision, address_line1, city, state, recorded_by) VALUES (1, 1, 1, '1 Example Street', 'Chicago', 'IL', 1);
INSERT INTO matter_property_snapshot_parcels (snapshot_id, pin) VALUES (1, '00-000-000-000');
UPDATE matter_property_snapshots SET sealed_at = now() WHERE id = 1;
SELECT pg_temp.expect_error($q$INSERT INTO matter_property_snapshot_parcels (snapshot_id, pin) VALUES (1, '00-000-000-001')$q$, 'P0001');
ROLLBACK;
\echo 'Database constraint and trigger checks passed.'
