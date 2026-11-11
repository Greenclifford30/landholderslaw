-- Draft only. Current readiness is calculated by the service, not by these rows.
ALTER TABLE closing_events ADD CONSTRAINT closing_events_matter_id_id_key UNIQUE(matter_id,id);
ALTER TABLE requirement_events ADD CONSTRAINT requirement_events_matter_id_id_key UNIQUE(matter_id,id);
ALTER TABLE requirement_evidence_events ADD CONSTRAINT requirement_evidence_events_matter_id_id_key UNIQUE(matter_id,id);
ALTER TABLE issue_readiness_assessments ADD CONSTRAINT issue_assessments_matter_id_id_key UNIQUE(matter_id,id);
ALTER TABLE exception_lifecycle_events ADD CONSTRAINT exception_lifecycle_events_matter_id_id_key UNIQUE(matter_id,id);
CREATE TABLE readiness_evaluations (
 id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT readiness_evaluations_pkey PRIMARY KEY,
 matter_id bigint NOT NULL, matter_workflow_id bigint NOT NULL, workflow_template_version_id bigint NOT NULL, template_validation_event_id bigint,
 result text NOT NULL, purpose text NOT NULL, evaluated_by bigint NOT NULL, evaluated_at timestamptz NOT NULL DEFAULT now(), created_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT readiness_evaluations_matter_id_id_key UNIQUE(matter_id,id),
 CONSTRAINT readiness_evaluations_workflow_fkey FOREIGN KEY(matter_id,matter_workflow_id,workflow_template_version_id) REFERENCES matter_workflows(matter_id,id,workflow_template_version_id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT readiness_evaluations_validation_fkey FOREIGN KEY(template_validation_event_id) REFERENCES workflow_template_validation_events(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT readiness_evaluations_actor_fkey FOREIGN KEY(evaluated_by) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT readiness_evaluations_result_check CHECK(result IN ('not_ready','ready','ready_with_exceptions')),
 CONSTRAINT readiness_evaluations_purpose_check CHECK(purpose IN ('review','transaction_closing'))
);
CREATE INDEX readiness_evaluations_matter_idx ON readiness_evaluations(matter_id,evaluated_at DESC,id DESC);
CREATE INDEX readiness_evaluations_workflow_idx ON readiness_evaluations(matter_id,matter_workflow_id,workflow_template_version_id);
CREATE INDEX readiness_evaluations_validation_idx ON readiness_evaluations(template_validation_event_id);
CREATE INDEX readiness_evaluations_actor_idx ON readiness_evaluations(evaluated_by);
CREATE TRIGGER readiness_evaluations_immutable BEFORE UPDATE OR DELETE ON readiness_evaluations FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TABLE readiness_evaluation_items (
 id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT readiness_evaluation_items_pkey PRIMARY KEY,
 matter_id bigint NOT NULL, readiness_evaluation_id bigint NOT NULL, requirement_id bigint, issue_id bigint, incident_id bigint,
 exception_revision_id bigint, finding_kind text NOT NULL, outcome text NOT NULL, description_snapshot text NOT NULL, created_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT readiness_items_matter_id_id_key UNIQUE(matter_id,id),
 CONSTRAINT readiness_items_evaluation_fkey FOREIGN KEY(matter_id,readiness_evaluation_id) REFERENCES readiness_evaluations(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT readiness_items_requirement_fkey FOREIGN KEY(matter_id,requirement_id) REFERENCES matter_requirements(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT readiness_items_issue_fkey FOREIGN KEY(matter_id,issue_id) REFERENCES matter_issues(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT readiness_items_incident_fkey FOREIGN KEY(matter_id,incident_id) REFERENCES unapproved_send_incidents(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT readiness_items_exception_fkey FOREIGN KEY(matter_id,exception_revision_id) REFERENCES exception_revisions(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT readiness_items_target_check CHECK((finding_kind='requirement' AND requirement_id IS NOT NULL AND issue_id IS NULL AND incident_id IS NULL) OR (finding_kind='issue' AND requirement_id IS NULL AND issue_id IS NOT NULL AND incident_id IS NULL) OR (finding_kind='incident' AND requirement_id IS NULL AND issue_id IS NULL AND incident_id IS NOT NULL) OR (finding_kind IN ('template_validation','primary_attorney') AND num_nonnulls(requirement_id,issue_id,incident_id)=0)),
 CONSTRAINT readiness_items_exception_check CHECK(exception_revision_id IS NULL OR (finding_kind='requirement' AND outcome='excepted')),
 CONSTRAINT readiness_items_outcome_check CHECK(outcome IN ('satisfied','not_satisfied','not_applicable','unresolved','nonblocking','blocking','excepted')),
 CONSTRAINT readiness_items_description_check CHECK(btrim(description_snapshot)<>'')
);
CREATE INDEX readiness_items_evaluation_idx ON readiness_evaluation_items(matter_id,readiness_evaluation_id);
CREATE INDEX readiness_items_requirement_idx ON readiness_evaluation_items(matter_id,requirement_id);
CREATE INDEX readiness_items_issue_idx ON readiness_evaluation_items(matter_id,issue_id);
CREATE INDEX readiness_items_incident_idx ON readiness_evaluation_items(matter_id,incident_id);
CREATE INDEX readiness_items_exception_idx ON readiness_evaluation_items(matter_id,exception_revision_id);
CREATE TRIGGER readiness_items_immutable BEFORE UPDATE OR DELETE ON readiness_evaluation_items FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TABLE readiness_evaluation_item_sources (
 id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT readiness_evaluation_item_sources_pkey PRIMARY KEY,
 matter_id bigint NOT NULL, readiness_evaluation_item_id bigint NOT NULL, requirement_event_id bigint, requirement_evidence_event_id bigint,
 issue_readiness_assessment_id bigint, unapproved_send_event_id bigint, approval_decision_id bigint, exception_lifecycle_event_id bigint,
 description_snapshot text, created_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT readiness_sources_item_fkey FOREIGN KEY(matter_id,readiness_evaluation_item_id) REFERENCES readiness_evaluation_items(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT readiness_sources_requirement_fkey FOREIGN KEY(matter_id,requirement_event_id) REFERENCES requirement_events(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT readiness_sources_evidence_fkey FOREIGN KEY(matter_id,requirement_evidence_event_id) REFERENCES requirement_evidence_events(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT readiness_sources_issue_fkey FOREIGN KEY(matter_id,issue_readiness_assessment_id) REFERENCES issue_readiness_assessments(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT readiness_sources_incident_fkey FOREIGN KEY(matter_id,unapproved_send_event_id) REFERENCES unapproved_send_events(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT readiness_sources_approval_fkey FOREIGN KEY(matter_id,approval_decision_id) REFERENCES approval_decisions(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT readiness_sources_exception_fkey FOREIGN KEY(matter_id,exception_lifecycle_event_id) REFERENCES exception_lifecycle_events(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT readiness_sources_target_check CHECK(num_nonnulls(requirement_event_id,requirement_evidence_event_id,issue_readiness_assessment_id,unapproved_send_event_id,approval_decision_id,exception_lifecycle_event_id)=1)
);
CREATE INDEX readiness_sources_item_idx ON readiness_evaluation_item_sources(matter_id,readiness_evaluation_item_id);
CREATE INDEX readiness_sources_requirement_idx ON readiness_evaluation_item_sources(matter_id,requirement_event_id);
CREATE INDEX readiness_sources_evidence_idx ON readiness_evaluation_item_sources(matter_id,requirement_evidence_event_id);
CREATE INDEX readiness_sources_issue_idx ON readiness_evaluation_item_sources(matter_id,issue_readiness_assessment_id);
CREATE INDEX readiness_sources_incident_idx ON readiness_evaluation_item_sources(matter_id,unapproved_send_event_id);
CREATE INDEX readiness_sources_approval_idx ON readiness_evaluation_item_sources(matter_id,approval_decision_id);
CREATE INDEX readiness_sources_exception_idx ON readiness_evaluation_item_sources(matter_id,exception_lifecycle_event_id);
CREATE TRIGGER readiness_sources_immutable BEFORE UPDATE OR DELETE ON readiness_evaluation_item_sources FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TABLE closing_readiness_records (
 id bigint GENERATED ALWAYS AS IDENTITY CONSTRAINT closing_readiness_records_pkey PRIMARY KEY,
 matter_id bigint NOT NULL, closing_event_id bigint NOT NULL, readiness_evaluation_id bigint NOT NULL, not_ready_reason text,
 recorded_by bigint NOT NULL, recorded_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT closing_readiness_closing_key UNIQUE(closing_event_id), CONSTRAINT closing_readiness_evaluation_key UNIQUE(readiness_evaluation_id),
 CONSTRAINT closing_readiness_event_fkey FOREIGN KEY(matter_id,closing_event_id) REFERENCES closing_events(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT closing_readiness_evaluation_fkey FOREIGN KEY(matter_id,readiness_evaluation_id) REFERENCES readiness_evaluations(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT closing_readiness_actor_fkey FOREIGN KEY(recorded_by) REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT
);
CREATE INDEX closing_readiness_event_idx ON closing_readiness_records(matter_id,closing_event_id);
CREATE INDEX closing_readiness_evaluation_idx ON closing_readiness_records(matter_id,readiness_evaluation_id);
CREATE INDEX closing_readiness_actor_idx ON closing_readiness_records(recorded_by);
CREATE TRIGGER closing_readiness_immutable BEFORE UPDATE OR DELETE ON closing_readiness_records FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
-- Atomic completeness, source-to-target consistency, closing kind and not-ready reason require service validation.
-- Evaluation findings and their sources are append-only but are not yet sealed against later inserts.
