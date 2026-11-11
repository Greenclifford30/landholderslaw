-- Documentation draft; authorization and lifecycle operations belong to transactional services.
CREATE TABLE correspondence (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, public_id uuid NOT NULL UNIQUE, matter_id bigint NOT NULL, title text NOT NULL,
 status text NOT NULL, created_by bigint NOT NULL, created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), row_version bigint NOT NULL DEFAULT 1,
 CONSTRAINT correspondence_matter_id_id_key UNIQUE(matter_id,id),
 CONSTRAINT correspondence_matter_fkey FOREIGN KEY(matter_id) REFERENCES matters(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT correspondence_creator_fkey FOREIGN KEY(created_by) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT correspondence_title_check CHECK(btrim(title)<>''), CONSTRAINT correspondence_version_check CHECK(row_version>0),
 CONSTRAINT correspondence_status_check CHECK(status IN ('draft','pending_review','changes_requested','approved','sent','withdrawn'))
);
CREATE INDEX correspondence_matter_status_idx ON correspondence(matter_id,status);
CREATE INDEX correspondence_creator_idx ON correspondence(created_by);
CREATE TRIGGER correspondence_updated BEFORE UPDATE ON correspondence FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TABLE correspondence_drafts (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint NOT NULL, correspondence_id bigint NOT NULL, revision integer NOT NULL,
 subject text NOT NULL, body text NOT NULL, delivery_method text NOT NULL, created_by bigint NOT NULL, created_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT correspondence_drafts_matter_id_id_key UNIQUE(matter_id,id), CONSTRAINT correspondence_drafts_correspondence_id_id_key UNIQUE(correspondence_id,id),
 CONSTRAINT correspondence_drafts_revision_key UNIQUE(correspondence_id,revision),
 CONSTRAINT correspondence_drafts_correspondence_fkey FOREIGN KEY(matter_id,correspondence_id) REFERENCES correspondence(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT correspondence_drafts_creator_fkey FOREIGN KEY(created_by) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT correspondence_drafts_revision_check CHECK(revision>0), CONSTRAINT correspondence_drafts_method_check CHECK(delivery_method IN ('email','mail','other'))
);
CREATE INDEX correspondence_drafts_parent_idx ON correspondence_drafts(matter_id,correspondence_id);
CREATE INDEX correspondence_drafts_creator_idx ON correspondence_drafts(created_by);
CREATE TRIGGER correspondence_drafts_immutable BEFORE UPDATE OR DELETE ON correspondence_drafts FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TABLE exception_requests (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, public_id uuid NOT NULL UNIQUE, matter_id bigint NOT NULL, kind text NOT NULL, status text NOT NULL,
 requested_by bigint NOT NULL, created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), row_version bigint NOT NULL DEFAULT 1,
 CONSTRAINT exception_requests_matter_id_id_key UNIQUE(matter_id,id),
 CONSTRAINT exception_requests_matter_fkey FOREIGN KEY(matter_id) REFERENCES matters(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT exception_requests_actor_fkey FOREIGN KEY(requested_by) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT exception_requests_kind_check CHECK(kind IN ('task_waiver','closing_override')),
 CONSTRAINT exception_requests_status_check CHECK(status IN ('draft','pending','approved','rejected','withdrawn','no_longer_needed','review_required','revoked')),
 CONSTRAINT exception_requests_version_check CHECK(row_version>0)
);
CREATE INDEX exception_requests_matter_status_idx ON exception_requests(matter_id,status);
CREATE INDEX exception_requests_actor_idx ON exception_requests(requested_by);
CREATE TRIGGER exception_requests_updated BEFORE UPDATE ON exception_requests FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TABLE exception_revisions (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint NOT NULL, exception_request_id bigint NOT NULL, revision integer NOT NULL,
 justification text NOT NULL, conditions text, created_by bigint NOT NULL, created_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT exception_revisions_matter_id_id_key UNIQUE(matter_id,id), CONSTRAINT exception_revisions_revision_key UNIQUE(exception_request_id,revision),
 CONSTRAINT exception_revisions_request_fkey FOREIGN KEY(matter_id,exception_request_id) REFERENCES exception_requests(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT exception_revisions_creator_fkey FOREIGN KEY(created_by) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT exception_revisions_number_check CHECK(revision>0), CONSTRAINT exception_revisions_justification_check CHECK(btrim(justification)<>'')
);
CREATE INDEX exception_revisions_parent_idx ON exception_revisions(matter_id,exception_request_id);
CREATE INDEX exception_revisions_creator_idx ON exception_revisions(created_by);
CREATE TRIGGER exception_revisions_immutable BEFORE UPDATE OR DELETE ON exception_revisions FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TABLE exception_targets (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint NOT NULL, exception_revision_id bigint NOT NULL, task_id bigint, requirement_id bigint,
 CONSTRAINT exception_targets_revision_fkey FOREIGN KEY(matter_id,exception_revision_id) REFERENCES exception_revisions(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT exception_targets_task_fkey FOREIGN KEY(matter_id,task_id) REFERENCES tasks(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT exception_targets_requirement_fkey FOREIGN KEY(matter_id,requirement_id) REFERENCES matter_requirements(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT exception_targets_target_check CHECK(num_nonnulls(task_id,requirement_id)=1)
);
CREATE UNIQUE INDEX exception_targets_task_key ON exception_targets(exception_revision_id,task_id) WHERE task_id IS NOT NULL;
CREATE UNIQUE INDEX exception_targets_requirement_key ON exception_targets(exception_revision_id,requirement_id) WHERE requirement_id IS NOT NULL;
CREATE INDEX exception_targets_revision_idx ON exception_targets(matter_id,exception_revision_id);
CREATE INDEX exception_targets_task_idx ON exception_targets(matter_id,task_id);
CREATE INDEX exception_targets_requirement_idx ON exception_targets(matter_id,requirement_id);
CREATE TABLE approval_requests (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, public_id uuid NOT NULL UNIQUE, matter_id bigint NOT NULL, draft_id bigint, exception_revision_id bigint,
 requested_by bigint NOT NULL, requested_at timestamptz NOT NULL DEFAULT now(), status text NOT NULL, row_version bigint NOT NULL DEFAULT 1,
 CONSTRAINT approval_requests_matter_id_id_key UNIQUE(matter_id,id),
 CONSTRAINT approval_requests_matter_fkey FOREIGN KEY(matter_id) REFERENCES matters(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT approval_requests_draft_fkey FOREIGN KEY(matter_id,draft_id) REFERENCES correspondence_drafts(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT approval_requests_exception_fkey FOREIGN KEY(matter_id,exception_revision_id) REFERENCES exception_revisions(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT approval_requests_requester_fkey FOREIGN KEY(requested_by) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT approval_requests_target_check CHECK(num_nonnulls(draft_id,exception_revision_id)=1),
 CONSTRAINT approval_requests_status_check CHECK(status IN ('pending','changes_requested','approved','rejected','withdrawn')),
 CONSTRAINT approval_requests_version_check CHECK(row_version>0)
);
CREATE UNIQUE INDEX approval_requests_pending_draft_key ON approval_requests(draft_id) WHERE status='pending' AND draft_id IS NOT NULL;
CREATE UNIQUE INDEX approval_requests_pending_exception_key ON approval_requests(exception_revision_id) WHERE status='pending' AND exception_revision_id IS NOT NULL;
CREATE INDEX approval_requests_pending_idx ON approval_requests(requested_at) WHERE status='pending';
CREATE INDEX approval_requests_matter_draft_idx ON approval_requests(matter_id,draft_id);
CREATE INDEX approval_requests_matter_exception_idx ON approval_requests(matter_id,exception_revision_id);
CREATE INDEX approval_requests_requester_idx ON approval_requests(requested_by);
CREATE TABLE approval_decisions (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint NOT NULL, approval_request_id bigint NOT NULL, decision text NOT NULL,
 comment text, attorney_user_id bigint NOT NULL, decided_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT approval_decisions_matter_id_id_key UNIQUE(matter_id,id), CONSTRAINT approval_decisions_request_key UNIQUE(approval_request_id),
 CONSTRAINT approval_decisions_request_fkey FOREIGN KEY(matter_id,approval_request_id) REFERENCES approval_requests(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT approval_decisions_attorney_fkey FOREIGN KEY(attorney_user_id) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT approval_decisions_decision_check CHECK(decision IN ('approved','rejected','changes_requested')),
 CONSTRAINT approval_decisions_comment_check CHECK(decision='approved' OR (comment IS NOT NULL AND btrim(comment)<>''))
);
CREATE INDEX approval_decisions_request_idx ON approval_decisions(matter_id,approval_request_id);
CREATE INDEX approval_decisions_attorney_idx ON approval_decisions(attorney_user_id);
CREATE TRIGGER approval_decisions_immutable BEFORE UPDATE OR DELETE ON approval_decisions FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TABLE outbox_events (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, event_key uuid NOT NULL UNIQUE, event_type text NOT NULL, matter_id bigint, payload jsonb NOT NULL,
 status text NOT NULL, available_at timestamptz NOT NULL, lease_until timestamptz, attempt_count integer NOT NULL DEFAULT 0,
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT outbox_events_matter_fkey FOREIGN KEY(matter_id) REFERENCES matters(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT outbox_events_type_check CHECK(btrim(event_type)<>''), CONSTRAINT outbox_events_attempt_check CHECK(attempt_count>=0),
 CONSTRAINT outbox_events_status_check CHECK(status IN ('queued','processing','published','retry','dead'))
);
CREATE INDEX outbox_events_matter_idx ON outbox_events(matter_id);
CREATE INDEX outbox_events_available_idx ON outbox_events(available_at,id) WHERE status IN ('queued','retry');
CREATE TRIGGER outbox_events_updated BEFORE UPDATE ON outbox_events FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TABLE audit_events (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint, actor_user_id bigint, origin text NOT NULL, action text NOT NULL,
 entity_type text NOT NULL, entity_id bigint, request_id uuid, changes jsonb, occurred_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT audit_events_matter_fkey FOREIGN KEY(matter_id) REFERENCES matters(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT audit_events_actor_fkey FOREIGN KEY(actor_user_id) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT audit_events_origin_check CHECK(origin IN ('user','system','bootstrap')),
 CONSTRAINT audit_events_actor_check CHECK(origin<>'user' OR actor_user_id IS NOT NULL),
 CONSTRAINT audit_events_text_check CHECK(btrim(action)<>'' AND btrim(entity_type)<>'')
);
CREATE INDEX audit_events_matter_time_idx ON audit_events(matter_id,occurred_at DESC,id DESC);
CREATE INDEX audit_events_actor_time_idx ON audit_events(actor_user_id,occurred_at DESC,id DESC);
CREATE TRIGGER audit_events_immutable BEFORE UPDATE OR DELETE ON audit_events FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
