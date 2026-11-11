-- Draft only; service validates authorization and changes with history atomically.
CREATE TABLE financial_confirmations (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, public_id uuid NOT NULL UNIQUE, matter_id bigint NOT NULL,
 kind text NOT NULL, created_by bigint NOT NULL, created_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT financial_confirmations_matter_id_id_key UNIQUE(matter_id,id),
 CONSTRAINT financial_confirmations_matter_fkey FOREIGN KEY(matter_id) REFERENCES matters(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT financial_confirmations_creator_fkey FOREIGN KEY(created_by) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT financial_confirmations_kind_check CHECK(kind IN ('retainer','earnest_money','closing_payment','other'))
);
CREATE INDEX financial_confirmations_matter_kind_idx ON financial_confirmations(matter_id,kind);
CREATE INDEX financial_confirmations_creator_idx ON financial_confirmations(created_by);
CREATE TABLE financial_confirmation_revisions (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint NOT NULL, financial_confirmation_id bigint NOT NULL,
 revision integer NOT NULL, status text NOT NULL, amount_cents bigint, currency text NOT NULL DEFAULT 'USD', effective_on date,
 reference text, receipt_document_version_id bigint, reason text, recorded_by bigint NOT NULL, recorded_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT financial_revisions_matter_id_id_key UNIQUE(matter_id,id),
 CONSTRAINT financial_revisions_confirmation_revision_key UNIQUE(financial_confirmation_id,revision),
 CONSTRAINT financial_revisions_confirmation_fkey FOREIGN KEY(matter_id,financial_confirmation_id) REFERENCES financial_confirmations(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT financial_revisions_document_fkey FOREIGN KEY(matter_id,receipt_document_version_id) REFERENCES document_versions(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT financial_revisions_actor_fkey FOREIGN KEY(recorded_by) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT financial_revisions_number_check CHECK(revision>0), CONSTRAINT financial_revisions_amount_check CHECK(amount_cents IS NULL OR amount_cents>=0),
 CONSTRAINT financial_revisions_currency_check CHECK(currency='USD'),
 CONSTRAINT financial_revisions_status_check CHECK(status IN ('expected','confirmed','corrected','canceled')),
 CONSTRAINT financial_revisions_reason_check CHECK(status<>'corrected' OR (reason IS NOT NULL AND btrim(reason)<>''))
);
CREATE INDEX financial_revisions_confirmation_idx ON financial_confirmation_revisions(matter_id,financial_confirmation_id);
CREATE INDEX financial_revisions_document_idx ON financial_confirmation_revisions(matter_id,receipt_document_version_id);
CREATE INDEX financial_revisions_actor_idx ON financial_confirmation_revisions(recorded_by);
CREATE TRIGGER financial_revisions_immutable BEFORE UPDATE OR DELETE ON financial_confirmation_revisions FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TABLE matter_requirements (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, public_id uuid NOT NULL UNIQUE, matter_id bigint NOT NULL,
 matter_workflow_id bigint, workflow_template_version_id bigint, requirement_template_id bigint, title text NOT NULL, kind text NOT NULL,
 applicability text NOT NULL, status text NOT NULL, is_required boolean NOT NULL, is_nonwaivable boolean NOT NULL, created_by bigint NOT NULL,
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), row_version bigint NOT NULL DEFAULT 1,
 CONSTRAINT matter_requirements_matter_id_id_key UNIQUE(matter_id,id),
 CONSTRAINT matter_requirements_matter_fkey FOREIGN KEY(matter_id) REFERENCES matters(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT matter_requirements_workflow_fkey FOREIGN KEY(matter_id,matter_workflow_id,workflow_template_version_id) REFERENCES matter_workflows(matter_id,id,workflow_template_version_id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT matter_requirements_template_fkey FOREIGN KEY(workflow_template_version_id,requirement_template_id) REFERENCES requirement_templates(workflow_template_version_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT matter_requirements_creator_fkey FOREIGN KEY(created_by) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT matter_requirements_provenance_check CHECK(num_nonnulls(matter_workflow_id,workflow_template_version_id,requirement_template_id) IN (0,3)),
 CONSTRAINT matter_requirements_title_check CHECK(btrim(title)<>''),
 CONSTRAINT matter_requirements_kind_check CHECK(kind IN ('document','task','other')),
 CONSTRAINT matter_requirements_status_check CHECK(status IN ('open','satisfied','canceled')),
 CONSTRAINT matter_requirements_applicability_check CHECK(applicability IN ('applicable','inapplicable','unresolved')),
 CONSTRAINT matter_requirements_nonwaivable_check CHECK(NOT is_nonwaivable OR is_required),
 CONSTRAINT matter_requirements_version_check CHECK(row_version>0)
);
CREATE UNIQUE INDEX matter_requirements_template_key ON matter_requirements(matter_workflow_id,requirement_template_id) WHERE requirement_template_id IS NOT NULL;
CREATE INDEX matter_requirements_matter_status_idx ON matter_requirements(matter_id,status,applicability);
CREATE INDEX matter_requirements_workflow_idx ON matter_requirements(matter_id,matter_workflow_id,workflow_template_version_id);
CREATE INDEX matter_requirements_template_idx ON matter_requirements(workflow_template_version_id,requirement_template_id);
CREATE INDEX matter_requirements_creator_idx ON matter_requirements(created_by);
CREATE TRIGGER matter_requirements_updated BEFORE UPDATE ON matter_requirements FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TABLE requirement_evidence (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint NOT NULL, requirement_id bigint NOT NULL,
 document_version_id bigint, task_id bigint, financial_confirmation_revision_id bigint, created_by bigint NOT NULL, created_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT requirement_evidence_matter_id_id_key UNIQUE(matter_id,id),
 CONSTRAINT requirement_evidence_requirement_fkey FOREIGN KEY(matter_id,requirement_id) REFERENCES matter_requirements(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT requirement_evidence_document_fkey FOREIGN KEY(matter_id,document_version_id) REFERENCES document_versions(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT requirement_evidence_task_fkey FOREIGN KEY(matter_id,task_id) REFERENCES tasks(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT requirement_evidence_financial_fkey FOREIGN KEY(matter_id,financial_confirmation_revision_id) REFERENCES financial_confirmation_revisions(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT requirement_evidence_creator_fkey FOREIGN KEY(created_by) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT requirement_evidence_target_check CHECK(num_nonnulls(document_version_id,task_id,financial_confirmation_revision_id)=1)
);
CREATE INDEX requirement_evidence_requirement_idx ON requirement_evidence(matter_id,requirement_id);
CREATE INDEX requirement_evidence_document_idx ON requirement_evidence(matter_id,document_version_id);
CREATE INDEX requirement_evidence_task_idx ON requirement_evidence(matter_id,task_id);
CREATE INDEX requirement_evidence_financial_idx ON requirement_evidence(matter_id,financial_confirmation_revision_id);
CREATE INDEX requirement_evidence_creator_idx ON requirement_evidence(created_by);
CREATE TRIGGER requirement_evidence_immutable BEFORE UPDATE OR DELETE ON requirement_evidence FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TABLE requirement_evidence_events (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint NOT NULL, requirement_evidence_id bigint NOT NULL,
 action text NOT NULL, reason text, actor_user_id bigint NOT NULL, occurred_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT requirement_evidence_events_evidence_fkey FOREIGN KEY(matter_id,requirement_evidence_id) REFERENCES requirement_evidence(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT requirement_evidence_events_actor_fkey FOREIGN KEY(actor_user_id) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT requirement_evidence_events_action_check CHECK(action IN ('linked','accepted','rejected','withdrawn')),
 CONSTRAINT requirement_evidence_events_reason_check CHECK(action NOT IN ('rejected','withdrawn') OR (reason IS NOT NULL AND btrim(reason)<>''))
);
CREATE INDEX requirement_evidence_events_evidence_idx ON requirement_evidence_events(matter_id,requirement_evidence_id,occurred_at DESC,id DESC);
CREATE INDEX requirement_evidence_events_actor_idx ON requirement_evidence_events(actor_user_id);
CREATE TRIGGER requirement_evidence_events_immutable BEFORE UPDATE OR DELETE ON requirement_evidence_events FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
