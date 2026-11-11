-- Proposed PostgreSQL 16+ DDL; apply after 001-004 in a disposable database.
-- Service must enforce authorization, history/current-state atomicity and policies.
CREATE TABLE document_categories (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, code text NOT NULL UNIQUE, label text NOT NULL,
 is_active boolean NOT NULL DEFAULT true, created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT document_categories_nonblank CHECK (btrim(code) <> '' AND btrim(label) <> '')
);
CREATE TRIGGER document_categories_updated BEFORE UPDATE ON document_categories FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TABLE deadline_types (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, code text NOT NULL UNIQUE, label text NOT NULL,
 is_active boolean NOT NULL DEFAULT true, created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT deadline_types_nonblank CHECK (btrim(code) <> '' AND btrim(label) <> '')
);
CREATE TRIGGER deadline_types_updated BEFORE UPDATE ON deadline_types FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TABLE documents (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, public_id uuid NOT NULL UNIQUE, matter_id bigint NOT NULL,
 document_category_id bigint NOT NULL, other_category_description text, title text NOT NULL, created_by bigint NOT NULL,
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), row_version bigint NOT NULL DEFAULT 1,
 is_historical boolean NOT NULL DEFAULT false, historical_note text,
 CONSTRAINT documents_matter_id_id_key UNIQUE (matter_id,id),
 CONSTRAINT documents_matter_fkey FOREIGN KEY (matter_id) REFERENCES matters(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT documents_category_fkey FOREIGN KEY (document_category_id) REFERENCES document_categories(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT documents_creator_fkey FOREIGN KEY (created_by) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT documents_title_check CHECK (btrim(title) <> ''), CONSTRAINT documents_version_check CHECK (row_version > 0)
);
CREATE INDEX documents_matter_category_idx ON documents (matter_id,document_category_id);
CREATE INDEX documents_category_idx ON documents (document_category_id);
CREATE INDEX documents_creator_idx ON documents (created_by);
CREATE TRIGGER documents_updated BEFORE UPDATE ON documents FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TABLE document_versions (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, public_id uuid NOT NULL UNIQUE, matter_id bigint NOT NULL, document_id bigint NOT NULL,
 version_number integer NOT NULL, storage_kind text NOT NULL, s3_bucket text, s3_key text, s3_version_id text,
 external_url_ciphertext bytea, external_url_key_reference text, checksum_sha256 text, size_bytes bigint, content_type text, provider text,
 created_by bigint NOT NULL, created_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT document_versions_matter_id_id_key UNIQUE (matter_id,id), CONSTRAINT document_versions_document_version_key UNIQUE (document_id,version_number),
 CONSTRAINT document_versions_document_fkey FOREIGN KEY (matter_id,document_id) REFERENCES documents(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT document_versions_creator_fkey FOREIGN KEY (created_by) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT document_versions_number_check CHECK (version_number > 0), CONSTRAINT document_versions_size_check CHECK (size_bytes IS NULL OR size_bytes >= 0),
 CONSTRAINT document_versions_checksum_check CHECK (checksum_sha256 IS NULL OR checksum_sha256 ~ '^[0-9a-fA-F]{64}$'),
 CONSTRAINT document_versions_storage_check CHECK (
  (storage_kind='upload' AND s3_bucket IS NOT NULL AND btrim(s3_bucket) <> '' AND s3_key IS NOT NULL AND btrim(s3_key) <> '' AND s3_version_id IS NOT NULL AND btrim(s3_version_id) <> '' AND external_url_ciphertext IS NULL AND external_url_key_reference IS NULL)
  OR (storage_kind='external' AND external_url_ciphertext IS NOT NULL AND octet_length(external_url_ciphertext)>0 AND external_url_key_reference IS NOT NULL AND btrim(external_url_key_reference)<>'' AND s3_bucket IS NULL AND s3_key IS NULL AND s3_version_id IS NULL))
);
CREATE INDEX document_versions_matter_document_idx ON document_versions (matter_id,document_id);
CREATE INDEX document_versions_creator_idx ON document_versions (created_by);
CREATE TRIGGER document_versions_immutable BEFORE UPDATE OR DELETE ON document_versions FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TABLE document_scan_events (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint NOT NULL, document_version_id bigint NOT NULL,
 outcome text NOT NULL, scanner_reference text, recorded_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT document_scan_events_version_fkey FOREIGN KEY (matter_id,document_version_id) REFERENCES document_versions(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT document_scan_events_outcome_check CHECK (outcome IN ('pending','passed','failed','error'))
);
CREATE INDEX document_scan_events_version_idx ON document_scan_events(matter_id,document_version_id,recorded_at DESC,id DESC);
CREATE TRIGGER document_scan_events_immutable BEFORE UPDATE OR DELETE ON document_scan_events FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TABLE deadlines (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, public_id uuid NOT NULL UNIQUE, matter_id bigint NOT NULL, deadline_type_id bigint NOT NULL,
 other_type_description text, title text NOT NULL, kind text NOT NULL, status text NOT NULL, due_on date NOT NULL, due_time time,
 timezone text NOT NULL DEFAULT 'America/Chicago', due_utc_offset_seconds integer, due_at timestamptz,
 owner_user_id bigint, reminders_enabled boolean NOT NULL DEFAULT true, created_by bigint NOT NULL,
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), row_version bigint NOT NULL DEFAULT 1,
 CONSTRAINT deadlines_matter_id_id_key UNIQUE(matter_id,id),
 CONSTRAINT deadlines_matter_fkey FOREIGN KEY(matter_id) REFERENCES matters(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT deadlines_type_fkey FOREIGN KEY(deadline_type_id) REFERENCES deadline_types(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT deadlines_owner_fkey FOREIGN KEY(owner_user_id) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT deadlines_creator_fkey FOREIGN KEY(created_by) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT deadlines_title_check CHECK (btrim(title)<>''), CONSTRAINT deadlines_timezone_check CHECK (btrim(timezone)<>''),
 CONSTRAINT deadlines_kind_check CHECK (kind IN ('contractual','internal')),
 CONSTRAINT deadlines_status_check CHECK (status IN ('open','satisfied','canceled','superseded')),
 CONSTRAINT deadlines_due_check CHECK ((due_time IS NULL AND due_utc_offset_seconds IS NULL AND due_at IS NULL) OR (due_time IS NOT NULL AND due_utc_offset_seconds IS NOT NULL AND due_at IS NOT NULL)),
 CONSTRAINT deadlines_version_check CHECK (row_version>0)
);
CREATE INDEX deadlines_matter_idx ON deadlines(matter_id);
CREATE INDEX deadlines_type_idx ON deadlines(deadline_type_id);
CREATE INDEX deadlines_owner_idx ON deadlines(owner_user_id,due_on);
CREATE INDEX deadlines_creator_idx ON deadlines(created_by);
CREATE INDEX deadlines_open_due_idx ON deadlines(due_on,matter_id) WHERE status='open';
CREATE TRIGGER deadlines_updated BEFORE UPDATE ON deadlines FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TABLE deadline_revisions (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint NOT NULL, deadline_id bigint NOT NULL, revision integer NOT NULL,
 deadline_type_id bigint NOT NULL, other_type_description text, due_on date NOT NULL, due_time time, timezone text NOT NULL,
 due_utc_offset_seconds integer, due_at timestamptz, source_document_version_id bigint, source_note text, reason text NOT NULL,
 actor_user_id bigint NOT NULL, recorded_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT deadline_revisions_matter_id_id_key UNIQUE(matter_id,id), CONSTRAINT deadline_revisions_deadline_id_id_key UNIQUE(deadline_id,id),
 CONSTRAINT deadline_revisions_deadline_revision_key UNIQUE(deadline_id,revision),
 CONSTRAINT deadline_revisions_deadline_fkey FOREIGN KEY(matter_id,deadline_id) REFERENCES deadlines(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT deadline_revisions_document_fkey FOREIGN KEY(matter_id,source_document_version_id) REFERENCES document_versions(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT deadline_revisions_type_fkey FOREIGN KEY(deadline_type_id) REFERENCES deadline_types(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT deadline_revisions_actor_fkey FOREIGN KEY(actor_user_id) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT deadline_revisions_number_check CHECK(revision>0), CONSTRAINT deadline_revisions_reason_check CHECK(btrim(reason)<>''),
 CONSTRAINT deadline_revisions_timezone_check CHECK(btrim(timezone)<>''),
 CONSTRAINT deadline_revisions_due_check CHECK ((due_time IS NULL AND due_utc_offset_seconds IS NULL AND due_at IS NULL) OR (due_time IS NOT NULL AND due_utc_offset_seconds IS NOT NULL AND due_at IS NOT NULL))
);
CREATE INDEX deadline_revisions_matter_deadline_idx ON deadline_revisions(matter_id,deadline_id);
CREATE INDEX deadline_revisions_document_idx ON deadline_revisions(matter_id,source_document_version_id);
CREATE INDEX deadline_revisions_type_idx ON deadline_revisions(deadline_type_id);
CREATE INDEX deadline_revisions_actor_idx ON deadline_revisions(actor_user_id);
CREATE TRIGGER deadline_revisions_immutable BEFORE UPDATE OR DELETE ON deadline_revisions FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TABLE deadline_extension_requests (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint NOT NULL, deadline_id bigint NOT NULL,
 proposed_due_on date NOT NULL, proposed_due_time time, status text NOT NULL, requested_by bigint NOT NULL,
 requested_at timestamptz NOT NULL DEFAULT now(), resolved_at timestamptz, note text,
 CONSTRAINT deadline_extensions_deadline_fkey FOREIGN KEY(matter_id,deadline_id) REFERENCES deadlines(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT deadline_extensions_actor_fkey FOREIGN KEY(requested_by) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT deadline_extensions_status_check CHECK(status IN ('pending','confirmed','rejected','withdrawn')),
 CONSTRAINT deadline_extensions_resolved_check CHECK((status='pending' AND resolved_at IS NULL) OR (status<>'pending' AND resolved_at IS NOT NULL AND resolved_at>=requested_at))
);
CREATE INDEX deadline_extensions_deadline_idx ON deadline_extension_requests(matter_id,deadline_id);
CREATE INDEX deadline_extensions_actor_idx ON deadline_extension_requests(requested_by);
CREATE TABLE closing_events (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint NOT NULL, event_type text NOT NULL,
 scheduled_at timestamptz, scheduled_timezone text, scheduled_utc_offset_seconds integer, location text,
 actual_at timestamptz, is_historical boolean NOT NULL DEFAULT false, reason text, actor_user_id bigint NOT NULL,
 recorded_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT closing_events_matter_fkey FOREIGN KEY(matter_id) REFERENCES matters(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT closing_events_actor_fkey FOREIGN KEY(actor_user_id) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT closing_events_type_check CHECK(event_type IN ('scheduled','rescheduled','closed','canceled')),
 CONSTRAINT closing_events_schedule_check CHECK(event_type NOT IN ('scheduled','rescheduled') OR (scheduled_at IS NOT NULL AND scheduled_timezone IS NOT NULL AND btrim(scheduled_timezone)<>'' AND scheduled_utc_offset_seconds IS NOT NULL)),
 CONSTRAINT closing_events_actual_check CHECK(event_type NOT IN ('closed','canceled') OR actual_at IS NOT NULL OR is_historical)
);
CREATE INDEX closing_events_matter_idx ON closing_events(matter_id,recorded_at DESC,id DESC);
CREATE INDEX closing_events_actor_idx ON closing_events(actor_user_id);
CREATE TRIGGER closing_events_immutable BEFORE UPDATE OR DELETE ON closing_events FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TABLE matter_issues (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, public_id uuid NOT NULL UNIQUE, matter_id bigint NOT NULL, title text NOT NULL,
 issue_type text NOT NULL, status text NOT NULL, severity text NOT NULL, owner_user_id bigint, deadline_id bigint,
 description text, resolution text, readiness_impact text NOT NULL DEFAULT 'unassessed', created_at timestamptz NOT NULL DEFAULT now(),
 updated_at timestamptz NOT NULL DEFAULT now(), row_version bigint NOT NULL DEFAULT 1,
 CONSTRAINT matter_issues_matter_id_id_key UNIQUE(matter_id,id),
 CONSTRAINT matter_issues_matter_fkey FOREIGN KEY(matter_id) REFERENCES matters(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT matter_issues_deadline_fkey FOREIGN KEY(matter_id,deadline_id) REFERENCES deadlines(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT matter_issues_owner_fkey FOREIGN KEY(owner_user_id) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT matter_issues_text_check CHECK(btrim(title)<>'' AND btrim(issue_type)<>''),
 CONSTRAINT matter_issues_status_check CHECK(status IN ('open','blocked','resolved','canceled')),
 CONSTRAINT matter_issues_severity_check CHECK(severity IN ('low','normal','high')),
 CONSTRAINT matter_issues_impact_check CHECK(readiness_impact IN ('unassessed','blocking','nonblocking')),
 CONSTRAINT matter_issues_resolution_check CHECK(status<>'resolved' OR (resolution IS NOT NULL AND btrim(resolution)<>'')),
 CONSTRAINT matter_issues_version_check CHECK(row_version>0)
);
CREATE INDEX matter_issues_matter_status_idx ON matter_issues(matter_id,status);
CREATE INDEX matter_issues_deadline_idx ON matter_issues(matter_id,deadline_id);
CREATE INDEX matter_issues_owner_idx ON matter_issues(owner_user_id);
CREATE TRIGGER matter_issues_updated BEFORE UPDATE ON matter_issues FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TABLE issue_readiness_assessments (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint NOT NULL, matter_issue_id bigint NOT NULL,
 impact text NOT NULL, reason text NOT NULL, actor_user_id bigint NOT NULL, assessed_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT issue_assessments_issue_fkey FOREIGN KEY(matter_id,matter_issue_id) REFERENCES matter_issues(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT issue_assessments_actor_fkey FOREIGN KEY(actor_user_id) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT issue_assessments_impact_check CHECK(impact IN ('blocking','nonblocking')),
 CONSTRAINT issue_assessments_reason_check CHECK(btrim(reason)<>'')
);
CREATE INDEX issue_assessments_issue_idx ON issue_readiness_assessments(matter_id,matter_issue_id,assessed_at DESC,id DESC);
CREATE INDEX issue_assessments_actor_idx ON issue_readiness_assessments(actor_user_id);
CREATE TRIGGER issue_assessments_immutable BEFORE UPDATE OR DELETE ON issue_readiness_assessments FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
