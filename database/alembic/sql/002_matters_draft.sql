-- Documentation draft only, PostgreSQL 16+. Apply after 001 in a disposable DB.
-- Allocation must be committed independently before matter creation; see ERD guide.

CREATE TABLE matter_number_counters (
    reference_year integer CONSTRAINT matter_number_counters_pkey PRIMARY KEY,
    last_value bigint NOT NULL,
    CONSTRAINT matter_number_counters_year_check CHECK (reference_year BETWEEN 1 AND 9999),
    CONSTRAINT matter_number_counters_last_value_check CHECK (last_value > 0)
);

CREATE TABLE matter_number_allocations (
    id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT matter_number_allocations_pkey PRIMARY KEY,
    reference_year integer NOT NULL,
    sequence_value bigint NOT NULL,
    allocation_token uuid NOT NULL,
    allocated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT matter_number_allocations_year_sequence_key UNIQUE (reference_year, sequence_value),
    CONSTRAINT matter_number_allocations_allocation_token_key UNIQUE (allocation_token),
    CONSTRAINT matter_number_allocations_year_check CHECK (reference_year BETWEEN 1 AND 9999),
    CONSTRAINT matter_number_allocations_sequence_check CHECK (sequence_value > 0)
);

CREATE TABLE matters (
    id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT matters_pkey PRIMARY KEY,
    public_id uuid NOT NULL,
    number_allocation_id bigint NOT NULL,
    matter_type text,
    title text,
    file_status text NOT NULL DEFAULT 'draft',
    transaction_status text NOT NULL DEFAULT 'pending',
    is_on_hold boolean NOT NULL DEFAULT false,
    is_restricted boolean NOT NULL DEFAULT false,
    contract_signed_on date,
    contract_price_cents bigint,
    created_by bigint NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    row_version bigint NOT NULL DEFAULT 1,
    CONSTRAINT matters_public_id_key UNIQUE (public_id),
    CONSTRAINT matters_number_allocation_id_key UNIQUE (number_allocation_id),
    CONSTRAINT matters_number_allocation_id_fkey FOREIGN KEY (number_allocation_id)
        REFERENCES matter_number_allocations (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT matters_created_by_fkey FOREIGN KEY (created_by)
        REFERENCES users (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT matters_type_check CHECK (matter_type IS NULL OR matter_type IN ('buyer', 'seller')),
    CONSTRAINT matters_title_check CHECK (title IS NULL OR btrim(title) <> ''),
    CONSTRAINT matters_file_status_check CHECK (file_status IN ('draft', 'open', 'closed')),
    CONSTRAINT matters_transaction_status_check CHECK (transaction_status IN ('pending', 'underway', 'closed', 'canceled')),
    CONSTRAINT matters_contract_price_check CHECK (contract_price_cents IS NULL OR contract_price_cents >= 0),
    CONSTRAINT matters_row_version_check CHECK (row_version > 0)
);
CREATE INDEX matters_created_by_idx ON matters (created_by);
CREATE INDEX matters_file_status_updated_at_idx ON matters (file_status, updated_at DESC);
CREATE INDEX matters_matter_type_file_status_idx ON matters (matter_type, file_status);
CREATE TRIGGER matters_set_updated_at BEFORE UPDATE ON matters
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE matter_parties (
    id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT matter_parties_pkey PRIMARY KEY,
    matter_id bigint NOT NULL,
    contact_id bigint NOT NULL,
    is_client boolean NOT NULL DEFAULT false,
    is_primary_client boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT matter_parties_matter_id_fkey FOREIGN KEY (matter_id)
        REFERENCES matters (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT matter_parties_contact_id_fkey FOREIGN KEY (contact_id)
        REFERENCES contacts (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT matter_parties_matter_id_contact_id_key UNIQUE (matter_id, contact_id),
    CONSTRAINT matter_parties_matter_id_id_key UNIQUE (matter_id, id),
    CONSTRAINT matter_parties_primary_is_client_check CHECK (NOT is_primary_client OR is_client)
);
CREATE UNIQUE INDEX matter_parties_primary_client_key ON matter_parties (matter_id) WHERE is_primary_client;
CREATE INDEX matter_parties_contact_id_matter_id_idx ON matter_parties (contact_id, matter_id);
CREATE INDEX matter_parties_clients_idx ON matter_parties (matter_id) WHERE is_client;

CREATE TABLE matter_properties (
    id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT matter_properties_pkey PRIMARY KEY,
    matter_id bigint NOT NULL,
    property_id bigint NOT NULL,
    is_primary boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT matter_properties_matter_id_fkey FOREIGN KEY (matter_id)
        REFERENCES matters (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT matter_properties_property_id_fkey FOREIGN KEY (property_id)
        REFERENCES properties (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT matter_properties_matter_id_property_id_key UNIQUE (matter_id, property_id),
    CONSTRAINT matter_properties_matter_id_id_key UNIQUE (matter_id, id)
);
CREATE UNIQUE INDEX matter_properties_primary_key ON matter_properties (matter_id) WHERE is_primary;
CREATE INDEX matter_properties_property_id_idx ON matter_properties (property_id);

CREATE TABLE matter_assignments (
    id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT matter_assignments_pkey PRIMARY KEY,
    matter_id bigint NOT NULL,
    user_id bigint NOT NULL,
    assignment_role text NOT NULL,
    is_primary boolean NOT NULL DEFAULT false,
    started_at timestamptz NOT NULL DEFAULT now(),
    ended_at timestamptz,
    assigned_by bigint NOT NULL,
    reason text,
    CONSTRAINT matter_assignments_matter_id_fkey FOREIGN KEY (matter_id)
        REFERENCES matters (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT matter_assignments_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES users (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT matter_assignments_assigned_by_fkey FOREIGN KEY (assigned_by)
        REFERENCES users (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT matter_assignments_role_check CHECK (assignment_role IN ('attorney', 'operations')),
    CONSTRAINT matter_assignments_time_check CHECK (ended_at IS NULL OR ended_at >= started_at)
);
CREATE UNIQUE INDEX matter_assignments_active_primary_key ON matter_assignments (matter_id, assignment_role)
    WHERE is_primary AND ended_at IS NULL;
CREATE UNIQUE INDEX matter_assignments_active_user_role_key ON matter_assignments (matter_id, user_id, assignment_role)
    WHERE ended_at IS NULL;
CREATE INDEX matter_assignments_matter_id_ended_at_idx ON matter_assignments (matter_id, ended_at);
CREATE INDEX matter_assignments_user_id_ended_at_idx ON matter_assignments (user_id, ended_at);
CREATE INDEX matter_assignments_assigned_by_idx ON matter_assignments (assigned_by);

CREATE TABLE matter_access_grants (
    id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT matter_access_grants_pkey PRIMARY KEY,
    matter_id bigint NOT NULL,
    user_id bigint NOT NULL,
    granted_by bigint NOT NULL,
    granted_at timestamptz NOT NULL DEFAULT now(),
    revoked_by bigint,
    revoked_at timestamptz,
    reason text,
    CONSTRAINT matter_access_grants_matter_id_fkey FOREIGN KEY (matter_id)
        REFERENCES matters (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT matter_access_grants_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES users (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT matter_access_grants_granted_by_fkey FOREIGN KEY (granted_by)
        REFERENCES users (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT matter_access_grants_revoked_by_fkey FOREIGN KEY (revoked_by)
        REFERENCES users (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT matter_access_grants_revocation_check CHECK (
        (revoked_by IS NULL AND revoked_at IS NULL) OR
        (revoked_by IS NOT NULL AND revoked_at IS NOT NULL AND revoked_at >= granted_at)
    )
);
CREATE UNIQUE INDEX matter_access_grants_active_key ON matter_access_grants (matter_id, user_id) WHERE revoked_at IS NULL;
CREATE INDEX matter_access_grants_matter_id_idx ON matter_access_grants (matter_id);
CREATE INDEX matter_access_grants_user_id_idx ON matter_access_grants (user_id);
CREATE INDEX matter_access_grants_granted_by_idx ON matter_access_grants (granted_by);
CREATE INDEX matter_access_grants_revoked_by_idx ON matter_access_grants (revoked_by);

CREATE TABLE matter_lifecycle_events (
    id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT matter_lifecycle_events_pkey PRIMARY KEY,
    matter_id bigint NOT NULL,
    event_type text NOT NULL,
    reason text,
    actor_user_id bigint NOT NULL,
    occurred_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT matter_lifecycle_events_matter_id_fkey FOREIGN KEY (matter_id)
        REFERENCES matters (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT matter_lifecycle_events_actor_user_id_fkey FOREIGN KEY (actor_user_id)
        REFERENCES users (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT matter_lifecycle_events_type_check CHECK (event_type IN
        ('activated', 'held', 'resumed', 'transaction_closed', 'transaction_canceled', 'file_closed', 'file_reopened')),
    CONSTRAINT matter_lifecycle_events_reason_check CHECK (
        event_type NOT IN ('transaction_canceled', 'file_closed', 'file_reopened') OR
        (reason IS NOT NULL AND btrim(reason) <> '')
    )
);
CREATE INDEX matter_lifecycle_events_matter_time_idx ON matter_lifecycle_events (matter_id, occurred_at DESC, id DESC);
CREATE INDEX matter_lifecycle_events_actor_user_id_idx ON matter_lifecycle_events (actor_user_id);

-- These triggers protect the ordinary write path; production roles and ownership
-- must prevent application users from disabling triggers or altering the schema.
CREATE FUNCTION reject_row_mutation() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION '% rows are immutable', TG_TABLE_NAME;
END;
$$;
CREATE TRIGGER matter_number_allocations_immutable BEFORE UPDATE OR DELETE ON matter_number_allocations
    FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TRIGGER matter_lifecycle_events_immutable BEFORE UPDATE OR DELETE ON matter_lifecycle_events
    FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();

CREATE FUNCTION protect_matter_number() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'matters cannot be deleted';
    END IF;
    IF NEW.number_allocation_id IS DISTINCT FROM OLD.number_allocation_id THEN
        RAISE EXCEPTION 'a matter number cannot be reassigned';
    END IF;
    RETURN NEW;
END;
$$;
CREATE TRIGGER matters_protect_number BEFORE UPDATE OR DELETE ON matters
    FOR EACH ROW EXECUTE FUNCTION protect_matter_number();

CREATE FUNCTION protect_matter_assignment() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'matter assignments cannot be deleted';
    END IF;
    IF OLD.ended_at IS NOT NULL OR NEW.ended_at IS NULL OR
       (NEW.id, NEW.matter_id, NEW.user_id, NEW.assignment_role, NEW.is_primary,
        NEW.started_at, NEW.assigned_by, NEW.reason)
       IS DISTINCT FROM
       (OLD.id, OLD.matter_id, OLD.user_id, OLD.assignment_role, OLD.is_primary,
        OLD.started_at, OLD.assigned_by, OLD.reason) THEN
        RAISE EXCEPTION 'only ending an active assignment is allowed';
    END IF;
    RETURN NEW;
END;
$$;
CREATE TRIGGER matter_assignments_protect_history BEFORE UPDATE OR DELETE ON matter_assignments
    FOR EACH ROW EXECUTE FUNCTION protect_matter_assignment();

CREATE FUNCTION protect_matter_access_grant() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'matter access grants cannot be deleted';
    END IF;
    IF OLD.revoked_at IS NOT NULL OR NEW.revoked_at IS NULL OR NEW.revoked_by IS NULL OR
       (NEW.id, NEW.matter_id, NEW.user_id, NEW.granted_by, NEW.granted_at, NEW.reason)
       IS DISTINCT FROM
       (OLD.id, OLD.matter_id, OLD.user_id, OLD.granted_by, OLD.granted_at, OLD.reason) THEN
        RAISE EXCEPTION 'only revoking an active grant is allowed';
    END IF;
    RETURN NEW;
END;
$$;
CREATE TRIGGER matter_access_grants_protect_history BEFORE UPDATE OR DELETE ON matter_access_grants
    FOR EACH ROW EXECUTE FUNCTION protect_matter_access_grant();

CREATE FUNCTION protect_matter_participation() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'matter participation cannot be deleted';
    END IF;
    IF TG_TABLE_NAME = 'matter_parties' THEN
        IF (NEW.id, NEW.matter_id, NEW.contact_id, NEW.created_at) IS DISTINCT FROM
           (OLD.id, OLD.matter_id, OLD.contact_id, OLD.created_at) THEN
            RAISE EXCEPTION 'matter party identity cannot be changed';
        END IF;
    ELSE
        IF (NEW.id, NEW.matter_id, NEW.property_id, NEW.created_at) IS DISTINCT FROM
           (OLD.id, OLD.matter_id, OLD.property_id, OLD.created_at) THEN
            RAISE EXCEPTION 'matter property identity cannot be changed';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;
CREATE TRIGGER matter_parties_protect_participation BEFORE UPDATE OR DELETE ON matter_parties
    FOR EACH ROW EXECUTE FUNCTION protect_matter_participation();
CREATE TRIGGER matter_properties_protect_participation BEFORE UPDATE OR DELETE ON matter_properties
    FOR EACH ROW EXECUTE FUNCTION protect_matter_participation();
