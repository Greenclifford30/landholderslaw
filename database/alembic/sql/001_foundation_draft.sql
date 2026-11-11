-- Documentation draft only: PostgreSQL 16+. Not an Alembic migration.
-- Review the ERD and data dictionary before using in any environment.
-- UUIDs are supplied by the application; timestamps use transaction time.

CREATE FUNCTION set_updated_at() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END;
$$;

CREATE TABLE users (
    id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT users_pkey PRIMARY KEY,
    public_id uuid NOT NULL,
    display_name text NOT NULL,
    email text NOT NULL,
    role text NOT NULL DEFAULT 'operations',
    is_admin boolean NOT NULL DEFAULT false,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    row_version bigint NOT NULL DEFAULT 1,
    CONSTRAINT users_public_id_key UNIQUE (public_id),
    CONSTRAINT users_display_name_check CHECK (btrim(display_name) <> ''),
    CONSTRAINT users_email_check CHECK (btrim(email) <> ''),
    CONSTRAINT users_role_check CHECK (role IN ('operations', 'attorney')),
    CONSTRAINT users_row_version_check CHECK (row_version > 0)
);
CREATE INDEX users_lower_email_idx ON users (lower(email));
CREATE TRIGGER users_set_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE user_identities (
    id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT user_identities_pkey PRIMARY KEY,
    user_id bigint NOT NULL,
    provider text NOT NULL,
    issuer text NOT NULL,
    subject text NOT NULL,
    last_verified_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT user_identities_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES users (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT user_identities_provider_issuer_subject_key UNIQUE (provider, issuer, subject),
    CONSTRAINT user_identities_user_id_provider_issuer_key UNIQUE (user_id, provider, issuer),
    CONSTRAINT user_identities_provider_check CHECK (provider IN ('google_workspace', 'sandbox')),
    CONSTRAINT user_identities_issuer_check CHECK (btrim(issuer) <> ''),
    CONSTRAINT user_identities_subject_check CHECK (btrim(subject) <> '')
);
-- The user_id-leading unique index also supports the foreign key.

CREATE TABLE contacts (
    id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT contacts_pkey PRIMARY KEY,
    public_id uuid NOT NULL,
    kind text NOT NULL,
    display_name text NOT NULL,
    given_name text,
    family_name text,
    organization_name text,
    is_active boolean NOT NULL DEFAULT true,
    created_by bigint NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    row_version bigint NOT NULL DEFAULT 1,
    CONSTRAINT contacts_public_id_key UNIQUE (public_id),
    CONSTRAINT contacts_created_by_fkey FOREIGN KEY (created_by)
        REFERENCES users (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT contacts_kind_check CHECK (kind IN ('person', 'organization')),
    CONSTRAINT contacts_display_name_check CHECK (btrim(display_name) <> ''),
    CONSTRAINT contacts_organization_name_check CHECK (
        kind <> 'organization' OR (organization_name IS NOT NULL AND btrim(organization_name) <> '')
    ),
    CONSTRAINT contacts_row_version_check CHECK (row_version > 0)
);
CREATE INDEX contacts_created_by_idx ON contacts (created_by);
CREATE INDEX contacts_lower_display_name_idx ON contacts (lower(display_name));
CREATE TRIGGER contacts_set_updated_at BEFORE UPDATE ON contacts
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE contact_methods (
    id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT contact_methods_pkey PRIMARY KEY,
    contact_id bigint NOT NULL,
    kind text NOT NULL,
    value text NOT NULL,
    label text,
    is_preferred boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT contact_methods_contact_id_fkey FOREIGN KEY (contact_id)
        REFERENCES contacts (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT contact_methods_kind_check CHECK (kind IN ('email', 'phone')),
    CONSTRAINT contact_methods_value_check CHECK (btrim(value) <> '')
);
CREATE INDEX contact_methods_contact_id_kind_idx ON contact_methods (contact_id, kind);
CREATE UNIQUE INDEX contact_methods_preferred_key ON contact_methods (contact_id, kind)
    WHERE is_preferred;
CREATE TRIGGER contact_methods_set_updated_at BEFORE UPDATE ON contact_methods
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE properties (
    id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT properties_pkey PRIMARY KEY,
    public_id uuid NOT NULL,
    address_line1 text NOT NULL,
    address_line2 text,
    city text NOT NULL,
    county text,
    state text NOT NULL DEFAULT 'IL',
    postal_code text,
    property_type text,
    unit_count integer,
    is_condominium boolean,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    row_version bigint NOT NULL DEFAULT 1,
    CONSTRAINT properties_public_id_key UNIQUE (public_id),
    CONSTRAINT properties_address_line1_check CHECK (btrim(address_line1) <> ''),
    CONSTRAINT properties_city_check CHECK (btrim(city) <> ''),
    CONSTRAINT properties_state_check CHECK (state = 'IL'),
    CONSTRAINT properties_unit_count_check CHECK (unit_count IS NULL OR unit_count > 0),
    CONSTRAINT properties_row_version_check CHECK (row_version > 0)
);
CREATE INDEX properties_lower_city_idx ON properties (lower(city));
CREATE TRIGGER properties_set_updated_at BEFORE UPDATE ON properties
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE property_parcels (
    id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT property_parcels_pkey PRIMARY KEY,
    property_id bigint NOT NULL,
    pin text NOT NULL,
    county text,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT property_parcels_property_id_fkey FOREIGN KEY (property_id)
        REFERENCES properties (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT property_parcels_pin_check CHECK (btrim(pin) <> '')
);
CREATE INDEX property_parcels_property_id_idx ON property_parcels (property_id);

-- Identity bindings require a privileged, audited correction procedure if wrong.
CREATE FUNCTION reject_identity_binding_changes() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'identity bindings cannot be deleted';
    END IF;
    IF (NEW.id, NEW.user_id, NEW.provider, NEW.issuer, NEW.subject, NEW.created_at)
       IS DISTINCT FROM (OLD.id, OLD.user_id, OLD.provider, OLD.issuer, OLD.subject, OLD.created_at) THEN
        RAISE EXCEPTION 'identity bindings cannot be reassigned';
    END IF;
    RETURN NEW;
END;
$$;
CREATE TRIGGER user_identities_protect_binding BEFORE UPDATE OR DELETE ON user_identities
    FOR EACH ROW EXECUTE FUNCTION reject_identity_binding_changes();
