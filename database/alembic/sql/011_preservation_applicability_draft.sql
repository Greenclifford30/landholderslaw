-- Draft only. Database rows do not themselves apply an S3 legal hold.
CREATE TABLE matter_legal_holds (
 id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT matter_legal_holds_pkey PRIMARY KEY,
 public_id uuid NOT NULL, matter_id bigint NOT NULL, reason text NOT NULL, status text NOT NULL DEFAULT 'active',
 placed_by bigint NOT NULL, placed_at timestamptz NOT NULL DEFAULT now(), released_by bigint, released_at timestamptz,
 release_reason text, created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), row_version bigint NOT NULL DEFAULT 1,
 CONSTRAINT matter_legal_holds_public_id_key UNIQUE(public_id), CONSTRAINT matter_legal_holds_matter_id_id_key UNIQUE(matter_id,id),
 CONSTRAINT matter_legal_holds_matter_fkey FOREIGN KEY(matter_id) REFERENCES matters(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT matter_legal_holds_placed_by_fkey FOREIGN KEY(placed_by) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT matter_legal_holds_released_by_fkey FOREIGN KEY(released_by) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT matter_legal_holds_reason_check CHECK(btrim(reason)<>''), CONSTRAINT matter_legal_holds_version_check CHECK(row_version>0),
 CONSTRAINT matter_legal_holds_release_check CHECK((status='active' AND released_by IS NULL AND released_at IS NULL AND release_reason IS NULL) OR (status='released' AND released_by IS NOT NULL AND released_at IS NOT NULL AND released_at>=placed_at AND release_reason IS NOT NULL AND btrim(release_reason)<>''))
);
CREATE INDEX matter_legal_holds_matter_status_idx ON matter_legal_holds(matter_id,status);
CREATE INDEX matter_legal_holds_placed_by_idx ON matter_legal_holds(placed_by);
CREATE INDEX matter_legal_holds_released_by_idx ON matter_legal_holds(released_by);
CREATE TRIGGER matter_legal_holds_updated BEFORE UPDATE ON matter_legal_holds FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TABLE legal_hold_object_protections (
 id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT hold_object_protections_pkey PRIMARY KEY,
 matter_id bigint NOT NULL, document_version_id bigint NOT NULL, status text NOT NULL, provider_object_version_id text NOT NULL,
 last_checked_at timestamptz, failure_code text, created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), row_version bigint NOT NULL DEFAULT 1,
 CONSTRAINT hold_object_protections_version_key UNIQUE(matter_id,document_version_id),
 CONSTRAINT hold_object_protections_version_fkey FOREIGN KEY(matter_id,document_version_id) REFERENCES document_versions(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT hold_object_protections_status_check CHECK(status IN ('pending','protected','release_pending','released','failed')),
 CONSTRAINT hold_object_protections_provider_check CHECK(btrim(provider_object_version_id)<>''),
 CONSTRAINT hold_object_protections_row_version_check CHECK(row_version>0)
);
CREATE INDEX hold_object_protections_matter_status_idx ON legal_hold_object_protections(matter_id,status);
CREATE INDEX hold_object_protections_status_updated_idx ON legal_hold_object_protections(status,updated_at);
CREATE TRIGGER hold_object_protections_updated BEFORE UPDATE ON legal_hold_object_protections FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TABLE legal_hold_protection_events (
 id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT hold_protection_events_pkey PRIMARY KEY,
 legal_hold_object_protection_id bigint NOT NULL, action text NOT NULL, outcome text NOT NULL, error_code text, recorded_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT hold_protection_events_protection_fkey FOREIGN KEY(legal_hold_object_protection_id) REFERENCES legal_hold_object_protections(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT hold_protection_events_action_check CHECK(action IN ('apply','verify','release')),
 CONSTRAINT hold_protection_events_outcome_check CHECK(outcome IN ('started','confirmed','failed','uncertain'))
);
CREATE INDEX hold_protection_events_parent_idx ON legal_hold_protection_events(legal_hold_object_protection_id,recorded_at DESC,id DESC);
CREATE TRIGGER hold_protection_events_immutable BEFORE UPDATE OR DELETE ON legal_hold_protection_events FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TABLE task_rule_evaluations (
 id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT task_rule_evaluations_pkey PRIMARY KEY,
 matter_id bigint NOT NULL, task_id bigint NOT NULL, workflow_task_template_id bigint NOT NULL, result text NOT NULL, facts jsonb NOT NULL,
 rule_version integer NOT NULL, actor_user_id bigint, evaluated_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT task_rule_evaluations_task_fkey FOREIGN KEY(matter_id,task_id) REFERENCES tasks(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT task_rule_evaluations_template_fkey FOREIGN KEY(workflow_task_template_id) REFERENCES workflow_task_templates(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT task_rule_evaluations_actor_fkey FOREIGN KEY(actor_user_id) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT task_rule_evaluations_result_check CHECK(result IN ('applicable','inapplicable','unresolved')),
 CONSTRAINT task_rule_evaluations_version_check CHECK(rule_version>0)
);
CREATE INDEX task_rule_evaluations_task_idx ON task_rule_evaluations(matter_id,task_id,evaluated_at DESC,id DESC);
CREATE INDEX task_rule_evaluations_template_idx ON task_rule_evaluations(workflow_task_template_id);
CREATE INDEX task_rule_evaluations_actor_idx ON task_rule_evaluations(actor_user_id);
CREATE TRIGGER task_rule_evaluations_immutable BEFORE UPDATE OR DELETE ON task_rule_evaluations FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TABLE applicability_overrides (
 id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT applicability_overrides_pkey PRIMARY KEY,
 matter_id bigint NOT NULL, task_id bigint, requirement_id bigint, decision text NOT NULL, reason text NOT NULL, actor_user_id bigint NOT NULL, decided_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT applicability_overrides_matter_id_id_key UNIQUE(matter_id,id),
 CONSTRAINT applicability_overrides_task_fkey FOREIGN KEY(matter_id,task_id) REFERENCES tasks(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT applicability_overrides_requirement_fkey FOREIGN KEY(matter_id,requirement_id) REFERENCES matter_requirements(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT applicability_overrides_actor_fkey FOREIGN KEY(actor_user_id) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT applicability_overrides_target_check CHECK(num_nonnulls(task_id,requirement_id)=1),
 CONSTRAINT applicability_overrides_decision_check CHECK(decision IN ('applicable','inapplicable')),
 CONSTRAINT applicability_overrides_reason_check CHECK(btrim(reason)<>'')
);
CREATE INDEX applicability_overrides_task_idx ON applicability_overrides(matter_id,task_id,decided_at DESC,id DESC);
CREATE INDEX applicability_overrides_requirement_idx ON applicability_overrides(matter_id,requirement_id,decided_at DESC,id DESC);
CREATE INDEX applicability_overrides_actor_idx ON applicability_overrides(actor_user_id);
CREATE TRIGGER applicability_overrides_immutable BEFORE UPDATE OR DELETE ON applicability_overrides FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TABLE applicability_override_events (
 id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT applicability_override_events_pkey PRIMARY KEY,
 matter_id bigint NOT NULL, applicability_override_id bigint NOT NULL, event_type text NOT NULL, reason text NOT NULL, actor_user_id bigint, occurred_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT applicability_events_override_fkey FOREIGN KEY(matter_id,applicability_override_id) REFERENCES applicability_overrides(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT applicability_events_actor_fkey FOREIGN KEY(actor_user_id) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT applicability_events_type_check CHECK(event_type IN ('review_required','confirmed','replaced')),
 CONSTRAINT applicability_events_actor_check CHECK(event_type='review_required' OR actor_user_id IS NOT NULL),
 CONSTRAINT applicability_events_reason_check CHECK(btrim(reason)<>'')
);
CREATE INDEX applicability_events_override_idx ON applicability_override_events(matter_id,applicability_override_id,occurred_at DESC,id DESC);
CREATE INDEX applicability_events_actor_idx ON applicability_override_events(actor_user_id);
CREATE TRIGGER applicability_events_immutable BEFORE UPDATE OR DELETE ON applicability_override_events FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TABLE closing_milestone_links (
 id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT closing_milestone_links_pkey PRIMARY KEY,
 matter_id bigint NOT NULL, task_id bigint, deadline_id bigint, offset_days integer NOT NULL, offset_basis text NOT NULL DEFAULT 'calendar',
 is_active boolean NOT NULL DEFAULT true, created_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT closing_milestones_task_fkey FOREIGN KEY(matter_id,task_id) REFERENCES tasks(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT closing_milestones_deadline_fkey FOREIGN KEY(matter_id,deadline_id) REFERENCES deadlines(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT closing_milestones_target_check CHECK(num_nonnulls(task_id,deadline_id)=1),
 CONSTRAINT closing_milestones_basis_check CHECK(offset_basis IN ('calendar','business'))
);
CREATE INDEX closing_milestones_matter_active_idx ON closing_milestone_links(matter_id,is_active);
CREATE INDEX closing_milestones_task_idx ON closing_milestone_links(matter_id,task_id);
CREATE INDEX closing_milestones_deadline_idx ON closing_milestone_links(matter_id,deadline_id);
CREATE TABLE document_classification_events (
 id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT document_classification_events_pkey PRIMARY KEY,
 matter_id bigint NOT NULL, document_id bigint NOT NULL, old_document_category_id bigint, new_document_category_id bigint NOT NULL,
 old_other_description text, new_other_description text, reason text NOT NULL, actor_user_id bigint NOT NULL, occurred_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT doc_classification_document_fkey FOREIGN KEY(matter_id,document_id) REFERENCES documents(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT doc_classification_old_category_fkey FOREIGN KEY(old_document_category_id) REFERENCES document_categories(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT doc_classification_new_category_fkey FOREIGN KEY(new_document_category_id) REFERENCES document_categories(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT doc_classification_actor_fkey FOREIGN KEY(actor_user_id) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT doc_classification_reason_check CHECK(btrim(reason)<>'')
);
CREATE INDEX doc_classification_document_idx ON document_classification_events(matter_id,document_id,occurred_at DESC,id DESC);
CREATE INDEX doc_classification_old_category_idx ON document_classification_events(old_document_category_id);
CREATE INDEX doc_classification_new_category_idx ON document_classification_events(new_document_category_id);
CREATE INDEX doc_classification_actor_idx ON document_classification_events(actor_user_id);
CREATE TRIGGER doc_classification_immutable BEFORE UPDATE OR DELETE ON document_classification_events FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TABLE document_copy_attestations (
 id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT document_copy_attestations_pkey PRIMARY KEY,
 matter_id bigint NOT NULL, external_document_version_id bigint NOT NULL, upload_document_version_id bigint NOT NULL,
 attested_by bigint NOT NULL, attested_at timestamptz NOT NULL DEFAULT now(), note text,
 CONSTRAINT document_copy_attestations_pair_key UNIQUE(external_document_version_id,upload_document_version_id),
 CONSTRAINT document_copy_attestations_external_fkey FOREIGN KEY(matter_id,external_document_version_id) REFERENCES document_versions(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT document_copy_attestations_upload_fkey FOREIGN KEY(matter_id,upload_document_version_id) REFERENCES document_versions(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT document_copy_attestations_actor_fkey FOREIGN KEY(attested_by) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT document_copy_attestations_distinct_check CHECK(external_document_version_id<>upload_document_version_id)
);
CREATE INDEX document_copy_attestations_external_idx ON document_copy_attestations(matter_id,external_document_version_id);
CREATE INDEX document_copy_attestations_upload_idx ON document_copy_attestations(matter_id,upload_document_version_id);
CREATE INDEX document_copy_attestations_actor_idx ON document_copy_attestations(attested_by);
CREATE TRIGGER document_copy_attestations_immutable BEFORE UPDATE OR DELETE ON document_copy_attestations FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TABLE exception_triggers (
 id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT exception_triggers_pkey PRIMARY KEY,
 matter_id bigint NOT NULL, exception_revision_id bigint NOT NULL, trigger_kind text NOT NULL, requirement_evidence_id bigint, note text,
 CONSTRAINT exception_triggers_revision_fkey FOREIGN KEY(matter_id,exception_revision_id) REFERENCES exception_revisions(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT exception_triggers_evidence_fkey FOREIGN KEY(matter_id,requirement_evidence_id) REFERENCES requirement_evidence(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT exception_triggers_unique UNIQUE NULLS NOT DISTINCT(exception_revision_id,trigger_kind,requirement_evidence_id),
 CONSTRAINT exception_triggers_kind_check CHECK((trigger_kind='closing_date' AND requirement_evidence_id IS NULL) OR (trigger_kind='document_evidence' AND requirement_evidence_id IS NOT NULL))
);
CREATE INDEX exception_triggers_revision_idx ON exception_triggers(matter_id,exception_revision_id);
CREATE INDEX exception_triggers_evidence_idx ON exception_triggers(matter_id,requirement_evidence_id);
CREATE TABLE exception_followup_tasks (
 id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT exception_followup_tasks_pkey PRIMARY KEY,
 matter_id bigint NOT NULL, exception_revision_id bigint NOT NULL, task_id bigint NOT NULL,
 CONSTRAINT exception_followup_tasks_unique UNIQUE(exception_revision_id,task_id),
 CONSTRAINT exception_followup_tasks_revision_fkey FOREIGN KEY(matter_id,exception_revision_id) REFERENCES exception_revisions(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT exception_followup_tasks_task_fkey FOREIGN KEY(matter_id,task_id) REFERENCES tasks(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT
);
CREATE INDEX exception_followup_tasks_revision_idx ON exception_followup_tasks(matter_id,exception_revision_id);
CREATE INDEX exception_followup_tasks_task_idx ON exception_followup_tasks(matter_id,task_id);
