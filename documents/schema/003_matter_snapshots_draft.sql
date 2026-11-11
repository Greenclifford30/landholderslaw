-- Documentation draft only. PostgreSQL 16+; apply after 001 and 002.
-- Snapshot headers are created unsealed, populated, and sealed in one transaction.
-- Readers must ignore unsealed snapshots; see the ERD guide.

CREATE TABLE matter_party_snapshots (
    id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT matter_party_snapshots_pkey PRIMARY KEY,
    matter_id bigint NOT NULL,
    matter_party_id bigint NOT NULL,
    revision integer NOT NULL,
    display_name text NOT NULL,
    source_contact_updated_at timestamptz,
    recorded_by bigint NOT NULL,
    recorded_at timestamptz NOT NULL DEFAULT now(),
    reason text,
    sealed_at timestamptz,
    CONSTRAINT matter_party_snapshots_party_fkey FOREIGN KEY (matter_id, matter_party_id)
        REFERENCES matter_parties (matter_id, id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT matter_party_snapshots_recorded_by_fkey FOREIGN KEY (recorded_by)
        REFERENCES users (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT matter_party_snapshots_party_revision_key UNIQUE (matter_party_id, revision),
    CONSTRAINT matter_party_snapshots_matter_id_id_key UNIQUE (matter_id, id),
    CONSTRAINT matter_party_snapshots_revision_check CHECK (revision > 0),
    CONSTRAINT matter_party_snapshots_display_name_check CHECK (btrim(display_name) <> ''),
    CONSTRAINT matter_party_snapshots_sealed_at_check CHECK (sealed_at IS NULL OR sealed_at >= recorded_at)
);
CREATE INDEX matter_party_snapshots_matter_party_idx ON matter_party_snapshots (matter_id, matter_party_id);
CREATE INDEX matter_party_snapshots_recorded_by_idx ON matter_party_snapshots (recorded_by);

CREATE TABLE matter_party_snapshot_methods (
    id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT matter_party_snapshot_methods_pkey PRIMARY KEY,
    snapshot_id bigint NOT NULL,
    kind text NOT NULL,
    value text NOT NULL,
    label text,
    is_preferred boolean NOT NULL DEFAULT false,
    CONSTRAINT matter_party_snapshot_methods_snapshot_id_fkey FOREIGN KEY (snapshot_id)
        REFERENCES matter_party_snapshots (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT matter_party_snapshot_methods_snapshot_kind_value_key UNIQUE (snapshot_id, kind, value),
    CONSTRAINT matter_party_snapshot_methods_kind_check CHECK (kind IN ('email', 'phone')),
    CONSTRAINT matter_party_snapshot_methods_value_check CHECK (btrim(value) <> '')
);
CREATE UNIQUE INDEX matter_party_snapshot_methods_preferred_key
    ON matter_party_snapshot_methods (snapshot_id, kind) WHERE is_preferred;

CREATE TABLE matter_property_snapshots (
    id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT matter_property_snapshots_pkey PRIMARY KEY,
    matter_id bigint NOT NULL,
    matter_property_id bigint NOT NULL,
    revision integer NOT NULL,
    address_line1 text NOT NULL,
    address_line2 text,
    city text NOT NULL,
    county text,
    state text NOT NULL,
    postal_code text,
    property_type text,
    unit_count integer,
    is_condominium boolean,
    recorded_by bigint NOT NULL,
    recorded_at timestamptz NOT NULL DEFAULT now(),
    reason text,
    sealed_at timestamptz,
    CONSTRAINT matter_property_snapshots_property_fkey FOREIGN KEY (matter_id, matter_property_id)
        REFERENCES matter_properties (matter_id, id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT matter_property_snapshots_recorded_by_fkey FOREIGN KEY (recorded_by)
        REFERENCES users (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT matter_property_snapshots_property_revision_key UNIQUE (matter_property_id, revision),
    CONSTRAINT matter_property_snapshots_matter_id_id_key UNIQUE (matter_id, id),
    CONSTRAINT matter_property_snapshots_revision_check CHECK (revision > 0),
    CONSTRAINT matter_property_snapshots_address_check CHECK (btrim(address_line1) <> ''),
    CONSTRAINT matter_property_snapshots_city_check CHECK (btrim(city) <> ''),
    CONSTRAINT matter_property_snapshots_state_check CHECK (state = 'IL'),
    CONSTRAINT matter_property_snapshots_unit_count_check CHECK (unit_count IS NULL OR unit_count > 0),
    CONSTRAINT matter_property_snapshots_sealed_at_check CHECK (sealed_at IS NULL OR sealed_at >= recorded_at)
);
CREATE INDEX matter_property_snapshots_matter_property_idx ON matter_property_snapshots (matter_id, matter_property_id);
CREATE INDEX matter_property_snapshots_recorded_by_idx ON matter_property_snapshots (recorded_by);

CREATE TABLE matter_property_snapshot_parcels (
    id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT matter_property_snapshot_parcels_pkey PRIMARY KEY,
    snapshot_id bigint NOT NULL,
    pin text NOT NULL,
    county text,
    CONSTRAINT matter_property_snapshot_parcels_snapshot_id_fkey FOREIGN KEY (snapshot_id)
        REFERENCES matter_property_snapshots (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT matter_property_snapshot_parcels_pin_check CHECK (btrim(pin) <> '')
);
CREATE INDEX matter_property_snapshot_parcels_snapshot_id_idx ON matter_property_snapshot_parcels (snapshot_id);

-- A header is immutable except for its one-way seal. Comparing JSONB here avoids
-- duplicating every header column; child writes lock the same header before insert.
CREATE FUNCTION protect_snapshot_header() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NEW.sealed_at IS NOT NULL THEN
            RAISE EXCEPTION 'snapshots must be created unsealed';
        END IF;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'snapshots cannot be deleted';
    END IF;
    IF OLD.sealed_at IS NOT NULL OR NEW.sealed_at IS NULL OR
       (to_jsonb(NEW) - 'sealed_at') IS DISTINCT FROM (to_jsonb(OLD) - 'sealed_at') THEN
        RAISE EXCEPTION 'only sealing an unsealed snapshot is allowed';
    END IF;
    RETURN NEW;
END;
$$;
CREATE TRIGGER matter_party_snapshots_protect BEFORE INSERT OR UPDATE OR DELETE ON matter_party_snapshots
    FOR EACH ROW EXECUTE FUNCTION protect_snapshot_header();
CREATE TRIGGER matter_property_snapshots_protect BEFORE INSERT OR UPDATE OR DELETE ON matter_property_snapshots
    FOR EACH ROW EXECUTE FUNCTION protect_snapshot_header();

CREATE FUNCTION protect_snapshot_child() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
    parent_sealed_at timestamptz;
BEGIN
    IF TG_OP <> 'INSERT' THEN
        RAISE EXCEPTION 'snapshot children cannot be changed or deleted';
    END IF;
    IF TG_TABLE_NAME = 'matter_party_snapshot_methods' THEN
        SELECT sealed_at INTO parent_sealed_at FROM matter_party_snapshots WHERE id = NEW.snapshot_id FOR UPDATE;
    ELSE
        SELECT sealed_at INTO parent_sealed_at FROM matter_property_snapshots WHERE id = NEW.snapshot_id FOR UPDATE;
    END IF;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'snapshot does not exist';
    END IF;
    IF parent_sealed_at IS NOT NULL THEN
        RAISE EXCEPTION 'cannot add children to a sealed snapshot';
    END IF;
    RETURN NEW;
END;
$$;
CREATE TRIGGER matter_party_snapshot_methods_protect BEFORE INSERT OR UPDATE OR DELETE ON matter_party_snapshot_methods
    FOR EACH ROW EXECUTE FUNCTION protect_snapshot_child();
CREATE TRIGGER matter_property_snapshot_parcels_protect BEFORE INSERT OR UPDATE OR DELETE ON matter_property_snapshot_parcels
    FOR EACH ROW EXECUTE FUNCTION protect_snapshot_child();
