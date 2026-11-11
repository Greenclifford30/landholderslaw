-- Draft only. Authorization and effective approval must be checked by transactional services.
-- A package is assembled and sealed in one transaction; only sealed drafts may be submitted.
ALTER TABLE correspondence_drafts ADD COLUMN sealed_at timestamptz;
DROP TRIGGER correspondence_drafts_immutable ON correspondence_drafts;
CREATE TRIGGER correspondence_drafts_seal BEFORE INSERT OR UPDATE OR DELETE ON correspondence_drafts FOR EACH ROW EXECUTE FUNCTION protect_snapshot_header();
CREATE TABLE draft_recipients (
 id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT draft_recipients_pkey PRIMARY KEY,
 matter_id bigint NOT NULL, draft_id bigint NOT NULL, recipient_kind text NOT NULL, display_name text, address text NOT NULL, contact_id bigint, sort_order integer NOT NULL,
 CONSTRAINT draft_recipients_draft_fkey FOREIGN KEY(matter_id,draft_id) REFERENCES correspondence_drafts(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT draft_recipients_contact_fkey FOREIGN KEY(contact_id) REFERENCES contacts(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT draft_recipients_address_check CHECK(btrim(address)<>''), CONSTRAINT draft_recipients_kind_check CHECK(recipient_kind IN ('to','cc','bcc','other'))
);
CREATE INDEX draft_recipients_draft_idx ON draft_recipients(matter_id,draft_id);
CREATE INDEX draft_recipients_contact_idx ON draft_recipients(contact_id);
CREATE TABLE draft_attachments (
 id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT draft_attachments_pkey PRIMARY KEY,
 matter_id bigint NOT NULL, draft_id bigint NOT NULL, document_version_id bigint NOT NULL, sort_order integer NOT NULL,
 CONSTRAINT draft_attachments_draft_version_key UNIQUE(draft_id,document_version_id),
 CONSTRAINT draft_attachments_draft_fkey FOREIGN KEY(matter_id,draft_id) REFERENCES correspondence_drafts(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT draft_attachments_document_fkey FOREIGN KEY(matter_id,document_version_id) REFERENCES document_versions(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT
);
CREATE INDEX draft_attachments_draft_idx ON draft_attachments(matter_id,draft_id);
CREATE INDEX draft_attachments_document_idx ON draft_attachments(matter_id,document_version_id);
CREATE FUNCTION protect_draft_package_child() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE parent_seal timestamptz;
BEGIN
 IF TG_OP<>'INSERT' THEN RAISE EXCEPTION 'draft package children cannot be updated or deleted'; END IF;
 SELECT sealed_at INTO parent_seal FROM correspondence_drafts WHERE matter_id=NEW.matter_id AND id=NEW.draft_id FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'draft missing' USING ERRCODE='23503'; END IF;
 IF parent_seal IS NOT NULL THEN RAISE EXCEPTION 'draft is sealed'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER draft_recipients_protect BEFORE INSERT OR UPDATE OR DELETE ON draft_recipients FOR EACH ROW EXECUTE FUNCTION protect_draft_package_child();
CREATE TRIGGER draft_attachments_protect BEFORE INSERT OR UPDATE OR DELETE ON draft_attachments FOR EACH ROW EXECUTE FUNCTION protect_draft_package_child();
CREATE FUNCTION require_sealed_approval_draft() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE parent_seal timestamptz;
BEGIN
 IF NEW.draft_id IS NOT NULL THEN
  SELECT sealed_at INTO parent_seal FROM correspondence_drafts WHERE matter_id=NEW.matter_id AND id=NEW.draft_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'draft missing' USING ERRCODE='23503'; END IF;
  IF parent_seal IS NULL THEN RAISE EXCEPTION 'draft must be sealed before review'; END IF;
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER approval_requests_sealed_draft BEFORE INSERT OR UPDATE ON approval_requests FOR EACH ROW EXECUTE FUNCTION require_sealed_approval_draft();
CREATE TABLE correspondence_materiality_decisions (
 id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT correspondence_materiality_decisions_pkey PRIMARY KEY,
 matter_id bigint NOT NULL, draft_id bigint NOT NULL, approval_decision_id bigint NOT NULL, attorney_user_id bigint NOT NULL,
 is_material boolean NOT NULL, reason text NOT NULL, decided_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT materiality_decisions_matter_id_id_key UNIQUE(matter_id,id),
 CONSTRAINT materiality_decisions_draft_fkey FOREIGN KEY(matter_id,draft_id) REFERENCES correspondence_drafts(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT materiality_decisions_approval_fkey FOREIGN KEY(matter_id,approval_decision_id) REFERENCES approval_decisions(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT materiality_decisions_attorney_fkey FOREIGN KEY(attorney_user_id) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT materiality_decisions_reason_check CHECK(btrim(reason)<>'')
);
CREATE INDEX materiality_decisions_draft_idx ON correspondence_materiality_decisions(matter_id,draft_id,decided_at DESC,id DESC);
CREATE INDEX materiality_decisions_approval_idx ON correspondence_materiality_decisions(matter_id,approval_decision_id);
CREATE INDEX materiality_decisions_attorney_idx ON correspondence_materiality_decisions(attorney_user_id);
CREATE TRIGGER materiality_decisions_immutable BEFORE UPDATE OR DELETE ON correspondence_materiality_decisions FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TABLE approval_revocations (
 id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT approval_revocations_pkey PRIMARY KEY,
 matter_id bigint NOT NULL, approval_decision_id bigint NOT NULL, attorney_user_id bigint NOT NULL, reason text NOT NULL, revoked_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT approval_revocations_decision_key UNIQUE(approval_decision_id),
 CONSTRAINT approval_revocations_decision_fkey FOREIGN KEY(matter_id,approval_decision_id) REFERENCES approval_decisions(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT approval_revocations_attorney_fkey FOREIGN KEY(attorney_user_id) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT approval_revocations_reason_check CHECK(btrim(reason)<>'')
);
CREATE INDEX approval_revocations_decision_idx ON approval_revocations(matter_id,approval_decision_id);
CREATE INDEX approval_revocations_attorney_idx ON approval_revocations(attorney_user_id);
CREATE TRIGGER approval_revocations_immutable BEFORE UPDATE OR DELETE ON approval_revocations FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TABLE correspondence_sends (
 id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT correspondence_sends_pkey PRIMARY KEY,
 matter_id bigint NOT NULL, correspondence_id bigint NOT NULL, draft_id bigint, approval_decision_id bigint, materiality_decision_id bigint,
 entry_kind text NOT NULL, sent_at timestamptz, sent_on date, sender_user_id bigint, external_sender text, method text NOT NULL, reference text,
 historical_note text, cutoff_on date, attesting_attorney_id bigint, attested_at timestamptz, entered_by bigint NOT NULL, recorded_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT correspondence_sends_matter_id_id_key UNIQUE(matter_id,id),
 CONSTRAINT correspondence_sends_correspondence_fkey FOREIGN KEY(matter_id,correspondence_id) REFERENCES correspondence(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT correspondence_sends_draft_fkey FOREIGN KEY(matter_id,draft_id) REFERENCES correspondence_drafts(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT correspondence_sends_approval_fkey FOREIGN KEY(matter_id,approval_decision_id) REFERENCES approval_decisions(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT correspondence_sends_materiality_fkey FOREIGN KEY(matter_id,materiality_decision_id) REFERENCES correspondence_materiality_decisions(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT correspondence_sends_sender_fkey FOREIGN KEY(sender_user_id) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT correspondence_sends_attorney_fkey FOREIGN KEY(attesting_attorney_id) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT correspondence_sends_entered_by_fkey FOREIGN KEY(entered_by) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT correspondence_sends_method_check CHECK(btrim(method)<>''),
 CONSTRAINT correspondence_sends_kind_check CHECK((entry_kind='current' AND draft_id IS NOT NULL AND approval_decision_id IS NOT NULL AND sender_user_id IS NOT NULL AND sent_at IS NOT NULL AND attesting_attorney_id IS NULL AND attested_at IS NULL) OR (entry_kind='historical' AND ((sent_on IS NOT NULL AND cutoff_on IS NOT NULL AND sent_on<cutoff_on) OR (sent_on IS NULL AND sent_at IS NULL AND attesting_attorney_id IS NOT NULL AND attested_at IS NOT NULL))))
);
CREATE INDEX correspondence_sends_correspondence_idx ON correspondence_sends(matter_id,correspondence_id,recorded_at DESC,id DESC);
CREATE INDEX correspondence_sends_draft_idx ON correspondence_sends(matter_id,draft_id);
CREATE INDEX correspondence_sends_approval_idx ON correspondence_sends(matter_id,approval_decision_id);
CREATE INDEX correspondence_sends_materiality_idx ON correspondence_sends(matter_id,materiality_decision_id);
CREATE INDEX correspondence_sends_sender_idx ON correspondence_sends(sender_user_id);
CREATE INDEX correspondence_sends_attorney_idx ON correspondence_sends(attesting_attorney_id);
CREATE INDEX correspondence_sends_entered_by_idx ON correspondence_sends(entered_by);
CREATE TRIGGER correspondence_sends_immutable BEFORE UPDATE OR DELETE ON correspondence_sends FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
ALTER TABLE correspondence_sends ADD CONSTRAINT correspondence_sends_parent_draft_fkey FOREIGN KEY(correspondence_id,draft_id) REFERENCES correspondence_drafts(correspondence_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT;
CREATE INDEX correspondence_sends_parent_draft_idx ON correspondence_sends(correspondence_id,draft_id);
CREATE TABLE unapproved_send_incidents (
 id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT unapproved_send_incidents_pkey PRIMARY KEY,
 public_id uuid NOT NULL, matter_id bigint NOT NULL, correspondence_id bigint NOT NULL, draft_id bigint, sent_at timestamptz, sent_on date,
 sender_user_id bigint, external_sender text, method text NOT NULL, description text NOT NULL, is_readiness_blocker boolean NOT NULL DEFAULT false,
 status text NOT NULL DEFAULT 'awaiting_review', recorded_by bigint NOT NULL, recorded_at timestamptz NOT NULL DEFAULT now(),
 updated_at timestamptz NOT NULL DEFAULT now(), row_version bigint NOT NULL DEFAULT 1,
 CONSTRAINT unapproved_incidents_public_id_key UNIQUE(public_id), CONSTRAINT unapproved_incidents_matter_id_id_key UNIQUE(matter_id,id),
 CONSTRAINT unapproved_incidents_correspondence_fkey FOREIGN KEY(matter_id,correspondence_id) REFERENCES correspondence(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT unapproved_incidents_draft_fkey FOREIGN KEY(matter_id,draft_id) REFERENCES correspondence_drafts(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT unapproved_incidents_parent_draft_fkey FOREIGN KEY(correspondence_id,draft_id) REFERENCES correspondence_drafts(correspondence_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT unapproved_incidents_sender_fkey FOREIGN KEY(sender_user_id) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT unapproved_incidents_recorder_fkey FOREIGN KEY(recorded_by) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT unapproved_incidents_text_check CHECK(btrim(description)<>'' AND btrim(method)<>''),
 CONSTRAINT unapproved_incidents_status_check CHECK(status IN ('awaiting_review','reviewed','disposed')),
 CONSTRAINT unapproved_incidents_version_check CHECK(row_version>0)
);
CREATE INDEX unapproved_incidents_matter_status_idx ON unapproved_send_incidents(matter_id,status);
CREATE INDEX unapproved_incidents_correspondence_idx ON unapproved_send_incidents(matter_id,correspondence_id);
CREATE INDEX unapproved_incidents_draft_idx ON unapproved_send_incidents(matter_id,draft_id);
CREATE INDEX unapproved_incidents_parent_draft_idx ON unapproved_send_incidents(correspondence_id,draft_id);
CREATE INDEX unapproved_incidents_sender_idx ON unapproved_send_incidents(sender_user_id);
CREATE INDEX unapproved_incidents_recorder_idx ON unapproved_send_incidents(recorded_by);
CREATE TRIGGER unapproved_incidents_updated BEFORE UPDATE ON unapproved_send_incidents FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TABLE unapproved_send_events (
 id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT unapproved_send_events_pkey PRIMARY KEY,
 matter_id bigint NOT NULL, incident_id bigint NOT NULL, event_type text NOT NULL, outcome text, notes text, reason text,
 actor_user_id bigint NOT NULL, occurred_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT unapproved_send_events_matter_id_id_key UNIQUE(matter_id,id),
 CONSTRAINT unapproved_send_events_incident_fkey FOREIGN KEY(matter_id,incident_id) REFERENCES unapproved_send_incidents(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT unapproved_send_events_actor_fkey FOREIGN KEY(actor_user_id) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT unapproved_send_events_type_check CHECK(event_type IN ('recorded','blocker_set','blocker_cleared','reviewed','disposed')),
 CONSTRAINT unapproved_send_events_reason_check CHECK(event_type NOT IN ('blocker_set','blocker_cleared','disposed') OR (reason IS NOT NULL AND btrim(reason)<>'')),
 CONSTRAINT unapproved_send_events_outcome_check CHECK(event_type<>'reviewed' OR (outcome IS NOT NULL AND btrim(outcome)<>''))
);
CREATE INDEX unapproved_send_events_incident_idx ON unapproved_send_events(matter_id,incident_id,occurred_at DESC,id DESC);
CREATE INDEX unapproved_send_events_actor_idx ON unapproved_send_events(actor_user_id);
CREATE TRIGGER unapproved_send_events_immutable BEFORE UPDATE OR DELETE ON unapproved_send_events FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TABLE unapproved_send_followup_tasks (
 id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT unapproved_send_followup_tasks_pkey PRIMARY KEY,
 matter_id bigint NOT NULL, incident_id bigint NOT NULL, task_id bigint NOT NULL,
 CONSTRAINT unapproved_followup_incident_task_key UNIQUE(incident_id,task_id),
 CONSTRAINT unapproved_followup_incident_fkey FOREIGN KEY(matter_id,incident_id) REFERENCES unapproved_send_incidents(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT unapproved_followup_task_fkey FOREIGN KEY(matter_id,task_id) REFERENCES tasks(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT
);
CREATE INDEX unapproved_followup_incident_idx ON unapproved_send_followup_tasks(matter_id,incident_id);
CREATE INDEX unapproved_followup_task_idx ON unapproved_send_followup_tasks(matter_id,task_id);
CREATE TABLE correspondence_send_recipients (
 id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT correspondence_send_recipients_pkey PRIMARY KEY,
 matter_id bigint NOT NULL, send_id bigint NOT NULL, recipient_kind text NOT NULL, address text NOT NULL, display_name text,
 CONSTRAINT send_recipients_send_fkey FOREIGN KEY(matter_id,send_id) REFERENCES correspondence_sends(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT send_recipients_address_check CHECK(btrim(address)<>''), CONSTRAINT send_recipients_kind_check CHECK(recipient_kind IN ('to','cc','bcc','other'))
);
CREATE INDEX send_recipients_send_idx ON correspondence_send_recipients(matter_id,send_id);
CREATE TRIGGER send_recipients_immutable BEFORE UPDATE OR DELETE ON correspondence_send_recipients FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TABLE correspondence_send_evidence (
 id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT correspondence_send_evidence_pkey PRIMARY KEY,
 matter_id bigint NOT NULL, send_id bigint NOT NULL, document_version_id bigint NOT NULL, note text,
 CONSTRAINT send_evidence_send_document_key UNIQUE(send_id,document_version_id),
 CONSTRAINT send_evidence_send_fkey FOREIGN KEY(matter_id,send_id) REFERENCES correspondence_sends(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT send_evidence_document_fkey FOREIGN KEY(matter_id,document_version_id) REFERENCES document_versions(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT
);
CREATE INDEX send_evidence_send_idx ON correspondence_send_evidence(matter_id,send_id);
CREATE INDEX send_evidence_document_idx ON correspondence_send_evidence(matter_id,document_version_id);
CREATE TRIGGER send_evidence_immutable BEFORE UPDATE OR DELETE ON correspondence_send_evidence FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
-- Service checks same-correspondence approval chains, materiality, role and revocation under locks.
-- Send recipients/evidence are append-only but their set is not sealed by this draft.
