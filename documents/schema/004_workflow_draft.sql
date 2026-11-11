-- Documentation draft for PostgreSQL 16+. Apply after 001-003; not a migration.
CREATE TABLE workflow_templates (
    id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT workflow_templates_pkey PRIMARY KEY,
    code text NOT NULL,
    name text NOT NULL,
    matter_type text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT workflow_templates_code_key UNIQUE (code),
    CONSTRAINT workflow_templates_code_check CHECK (btrim(code) <> ''),
    CONSTRAINT workflow_templates_name_check CHECK (btrim(name) <> ''),
    CONSTRAINT workflow_templates_matter_type_check CHECK (matter_type IN ('buyer', 'seller'))
);
CREATE TABLE workflow_template_versions (
    id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT workflow_template_versions_pkey PRIMARY KEY,
    workflow_template_id bigint NOT NULL,
    version integer NOT NULL,
    status text NOT NULL DEFAULT 'draft',
    published_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT workflow_versions_template_fkey FOREIGN KEY (workflow_template_id) REFERENCES workflow_templates (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT workflow_versions_template_version_key UNIQUE (workflow_template_id, version),
    CONSTRAINT workflow_versions_version_check CHECK (version > 0),
    CONSTRAINT workflow_versions_status_check CHECK (status IN ('draft', 'published', 'retired')),
    CONSTRAINT workflow_versions_published_check CHECK ((status = 'draft' AND published_at IS NULL) OR (status IN ('published', 'retired') AND published_at IS NOT NULL))
);
CREATE TABLE workflow_phases (
    id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT workflow_phases_pkey PRIMARY KEY,
    workflow_template_version_id bigint NOT NULL,
    phase_key text NOT NULL,
    name text NOT NULL,
    sort_order integer NOT NULL,
    CONSTRAINT workflow_phases_version_fkey FOREIGN KEY (workflow_template_version_id) REFERENCES workflow_template_versions (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT workflow_phases_version_key_key UNIQUE (workflow_template_version_id, phase_key),
    CONSTRAINT workflow_phases_version_id_key UNIQUE (workflow_template_version_id, id),
    CONSTRAINT workflow_phases_key_check CHECK (btrim(phase_key) <> ''),
    CONSTRAINT workflow_phases_name_check CHECK (btrim(name) <> '')
);
CREATE TABLE workflow_task_templates (
    id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT workflow_task_templates_pkey PRIMARY KEY,
    workflow_template_version_id bigint NOT NULL,
    workflow_phase_id bigint NOT NULL,
    task_key text NOT NULL,
    title text NOT NULL,
    description text,
    sort_order integer NOT NULL,
    is_required boolean NOT NULL DEFAULT true,
    applicability_rule jsonb,
    CONSTRAINT workflow_task_templates_phase_fkey FOREIGN KEY (workflow_template_version_id, workflow_phase_id) REFERENCES workflow_phases (workflow_template_version_id, id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT workflow_task_templates_version_task_key UNIQUE (workflow_template_version_id, task_key),
    CONSTRAINT workflow_task_templates_version_id_key UNIQUE (workflow_template_version_id, id),
    CONSTRAINT workflow_task_templates_key_check CHECK (btrim(task_key) <> ''),
    CONSTRAINT workflow_task_templates_title_check CHECK (btrim(title) <> '')
);
CREATE INDEX workflow_task_templates_phase_idx ON workflow_task_templates (workflow_template_version_id, workflow_phase_id);
CREATE TABLE requirement_templates (
    id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT requirement_templates_pkey PRIMARY KEY,
    workflow_template_version_id bigint NOT NULL,
    requirement_key text NOT NULL,
    title text NOT NULL,
    description text,
    kind text NOT NULL,
    is_required boolean NOT NULL,
    is_nonwaivable boolean NOT NULL,
    applicability_rule jsonb,
    sort_order integer NOT NULL,
    CONSTRAINT requirement_templates_version_fkey FOREIGN KEY (workflow_template_version_id) REFERENCES workflow_template_versions (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT requirement_templates_version_key_key UNIQUE (workflow_template_version_id, requirement_key),
    CONSTRAINT requirement_templates_version_id_key UNIQUE (workflow_template_version_id, id),
    CONSTRAINT requirement_templates_key_check CHECK (btrim(requirement_key) <> ''),
    CONSTRAINT requirement_templates_title_check CHECK (btrim(title) <> ''),
    CONSTRAINT requirement_templates_kind_check CHECK (kind IN ('document', 'task', 'other')),
    CONSTRAINT requirement_templates_nonwaivable_check CHECK (NOT is_nonwaivable OR is_required)
);
CREATE TABLE matter_workflows (
    id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT matter_workflows_pkey PRIMARY KEY,
    matter_id bigint NOT NULL,
    workflow_template_version_id bigint NOT NULL,
    instantiated_at timestamptz NOT NULL DEFAULT now(),
    instantiated_by bigint NOT NULL,
    CONSTRAINT matter_workflows_matter_fkey FOREIGN KEY (matter_id) REFERENCES matters (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT matter_workflows_version_fkey FOREIGN KEY (workflow_template_version_id) REFERENCES workflow_template_versions (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT matter_workflows_actor_fkey FOREIGN KEY (instantiated_by) REFERENCES users (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT matter_workflows_matter_key UNIQUE (matter_id),
    CONSTRAINT matter_workflows_matter_id_key UNIQUE (matter_id, id),
    CONSTRAINT matter_workflows_matter_id_version_key UNIQUE (matter_id, id, workflow_template_version_id)
);
CREATE INDEX matter_workflows_version_idx ON matter_workflows (workflow_template_version_id);
CREATE INDEX matter_workflows_actor_idx ON matter_workflows (instantiated_by);
CREATE TRIGGER matter_workflows_immutable BEFORE UPDATE OR DELETE ON matter_workflows FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();

CREATE TABLE tasks (
    id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT tasks_pkey PRIMARY KEY,
    public_id uuid NOT NULL,
    matter_id bigint NOT NULL,
    matter_workflow_id bigint,
    workflow_template_version_id bigint,
    workflow_task_template_id bigint,
    source text NOT NULL,
    title text NOT NULL,
    description text,
    assigned_to bigint,
    status text NOT NULL DEFAULT 'pending',
    applicability text NOT NULL DEFAULT 'applicable',
    is_required boolean NOT NULL,
    due_on date,
    due_time time,
    due_timezone text,
    due_utc_offset_seconds integer,
    due_at timestamptz,
    created_by bigint NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    row_version bigint NOT NULL DEFAULT 1,
    CONSTRAINT tasks_public_id_key UNIQUE (public_id),
    CONSTRAINT tasks_matter_id_id_key UNIQUE (matter_id, id),
    CONSTRAINT tasks_matter_fkey FOREIGN KEY (matter_id) REFERENCES matters (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT tasks_workflow_fkey FOREIGN KEY (matter_id, matter_workflow_id, workflow_template_version_id) REFERENCES matter_workflows (matter_id, id, workflow_template_version_id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT tasks_template_fkey FOREIGN KEY (workflow_template_version_id, workflow_task_template_id) REFERENCES workflow_task_templates (workflow_template_version_id, id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT tasks_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES users (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT tasks_created_by_fkey FOREIGN KEY (created_by) REFERENCES users (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT tasks_source_check CHECK ((source = 'standard' AND matter_workflow_id IS NOT NULL AND workflow_template_version_id IS NOT NULL AND workflow_task_template_id IS NOT NULL) OR (source = 'manual' AND matter_workflow_id IS NULL AND workflow_template_version_id IS NULL AND workflow_task_template_id IS NULL)),
    CONSTRAINT tasks_title_check CHECK (btrim(title) <> ''),
    CONSTRAINT tasks_status_check CHECK (status IN ('pending','in_progress','waiting','under_review','blocked','completed','canceled','waived')),
    CONSTRAINT tasks_applicability_check CHECK (applicability IN ('applicable','inapplicable','unresolved')),
    CONSTRAINT tasks_due_check CHECK ((due_time IS NULL AND due_timezone IS NULL AND due_utc_offset_seconds IS NULL AND due_at IS NULL) OR (due_on IS NOT NULL AND due_time IS NOT NULL AND due_timezone IS NOT NULL AND btrim(due_timezone) <> '' AND due_utc_offset_seconds IS NOT NULL AND due_at IS NOT NULL)),
    CONSTRAINT tasks_row_version_check CHECK (row_version > 0)
);
CREATE UNIQUE INDEX tasks_standard_template_key ON tasks (matter_workflow_id, workflow_task_template_id) WHERE source = 'standard';
CREATE INDEX tasks_workflow_idx ON tasks (matter_id, matter_workflow_id, workflow_template_version_id);
CREATE INDEX tasks_template_idx ON tasks (workflow_template_version_id, workflow_task_template_id);
CREATE INDEX tasks_created_by_idx ON tasks (created_by);
CREATE INDEX tasks_assigned_to_idx ON tasks (assigned_to, due_on);
CREATE INDEX tasks_matter_status_idx ON tasks (matter_id, status);
CREATE TRIGGER tasks_set_updated_at BEFORE UPDATE ON tasks FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TABLE task_dependencies (
    id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT task_dependencies_pkey PRIMARY KEY,
    matter_id bigint NOT NULL,
    task_id bigint NOT NULL,
    depends_on_task_id bigint NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT task_dependencies_task_fkey FOREIGN KEY (matter_id, task_id) REFERENCES tasks (matter_id, id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT task_dependencies_prereq_fkey FOREIGN KEY (matter_id, depends_on_task_id) REFERENCES tasks (matter_id, id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT task_dependencies_edge_key UNIQUE (task_id, depends_on_task_id),
    CONSTRAINT task_dependencies_matter_id_id_key UNIQUE (matter_id, id),
    CONSTRAINT task_dependencies_no_self_check CHECK (task_id <> depends_on_task_id)
);
CREATE INDEX task_dependencies_matter_task_idx ON task_dependencies (matter_id, task_id);
CREATE INDEX task_dependencies_matter_prereq_idx ON task_dependencies (matter_id, depends_on_task_id);

-- Definition edits and publication lock the same parent row, serializing races.
CREATE FUNCTION protect_workflow_version() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NEW.status <> 'draft' THEN RAISE EXCEPTION 'workflow versions must start as drafts'; END IF;
        RETURN NEW;
    END IF;
    IF TG_OP = 'DELETE' THEN
        IF OLD.status <> 'draft' THEN RAISE EXCEPTION 'published workflow versions cannot be deleted'; END IF;
        RETURN OLD;
    END IF;
    IF OLD.status = 'draft' THEN
        IF NEW.status NOT IN ('draft','published') THEN RAISE EXCEPTION 'invalid workflow transition'; END IF;
    ELSIF OLD.status = 'published' THEN
        IF NEW.status <> 'retired' OR
           (to_jsonb(NEW) - 'status') IS DISTINCT FROM (to_jsonb(OLD) - 'status') THEN
            RAISE EXCEPTION 'published versions can only be retired';
        END IF;
    ELSE
        RAISE EXCEPTION 'retired workflow versions are immutable';
    END IF;
    RETURN NEW;
END;
$$;
CREATE TRIGGER workflow_versions_protect BEFORE INSERT OR UPDATE OR DELETE ON workflow_template_versions FOR EACH ROW EXECUTE FUNCTION protect_workflow_version();
CREATE FUNCTION protect_workflow_child() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE version_id bigint; version_status text;
BEGIN
    IF TG_OP = 'UPDATE' AND NEW.workflow_template_version_id IS DISTINCT FROM OLD.workflow_template_version_id THEN
        RAISE EXCEPTION 'workflow definitions cannot move between versions';
    END IF;
    IF TG_OP = 'DELETE' THEN version_id := OLD.workflow_template_version_id; ELSE version_id := NEW.workflow_template_version_id; END IF;
    SELECT status INTO version_status FROM workflow_template_versions WHERE id = version_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'workflow version missing' USING ERRCODE = '23503'; END IF;
    IF version_status <> 'draft' THEN RAISE EXCEPTION 'published workflow definitions are immutable'; END IF;
    IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
    RETURN NEW;
END;
$$;
CREATE TRIGGER workflow_phases_protect BEFORE INSERT OR UPDATE OR DELETE ON workflow_phases FOR EACH ROW EXECUTE FUNCTION protect_workflow_child();
CREATE TRIGGER workflow_task_templates_protect BEFORE INSERT OR UPDATE OR DELETE ON workflow_task_templates FOR EACH ROW EXECUTE FUNCTION protect_workflow_child();
CREATE TRIGGER requirement_templates_protect BEFORE INSERT OR UPDATE OR DELETE ON requirement_templates FOR EACH ROW EXECUTE FUNCTION protect_workflow_child();
-- Stable template identity also prevents later changes to a version's meaning.
CREATE TRIGGER workflow_templates_immutable BEFORE UPDATE OR DELETE ON workflow_templates FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE FUNCTION validate_matter_workflow() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE template_type text; version_status text; current_type text;
BEGIN
    SELECT matter_type INTO current_type FROM matters WHERE id = NEW.matter_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'matter not found' USING ERRCODE = '23503'; END IF;
    SELECT v.status, t.matter_type INTO version_status, template_type
      FROM workflow_template_versions v JOIN workflow_templates t ON t.id = v.workflow_template_id
      WHERE v.id = NEW.workflow_template_version_id FOR UPDATE OF v;
    IF NOT FOUND OR version_status <> 'published' THEN RAISE EXCEPTION 'workflow version must be published'; END IF;
    IF current_type IS DISTINCT FROM template_type THEN RAISE EXCEPTION 'workflow type must match matter'; END IF;
    RETURN NEW;
END;
$$;
CREATE TRIGGER matter_workflows_validate BEFORE INSERT ON matter_workflows FOR EACH ROW EXECUTE FUNCTION validate_matter_workflow();

CREATE FUNCTION protect_workflow_matter_type() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.matter_type IS DISTINCT FROM OLD.matter_type AND EXISTS (SELECT 1 FROM matter_workflows WHERE matter_id = OLD.id) THEN
        RAISE EXCEPTION 'matter type cannot change after workflow instantiation';
    END IF;
    RETURN NEW;
END;
$$;
CREATE TRIGGER matters_protect_workflow_type BEFORE UPDATE ON matters FOR EACH ROW EXECUTE FUNCTION protect_workflow_matter_type();
