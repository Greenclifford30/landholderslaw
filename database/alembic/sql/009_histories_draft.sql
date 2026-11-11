-- Draft: history must be written atomically with its corresponding current state.
CREATE TABLE user_role_events (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, user_id bigint NOT NULL REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 actor_user_id bigint REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT, origin text NOT NULL, old_role text, new_role text NOT NULL,
 old_is_admin boolean, new_is_admin boolean NOT NULL, reason text, occurred_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT user_role_events_origin_check CHECK(origin IN ('admin','bootstrap') AND (origin='bootstrap' OR actor_user_id IS NOT NULL)),
 CONSTRAINT user_role_events_roles_check CHECK(new_role IN ('operations','attorney') AND (old_role IS NULL OR old_role IN ('operations','attorney')))
);
CREATE INDEX user_role_events_user_idx ON user_role_events(user_id,occurred_at DESC,id DESC);
CREATE INDEX user_role_events_actor_idx ON user_role_events(actor_user_id);
CREATE TRIGGER user_role_events_immutable BEFORE UPDATE OR DELETE ON user_role_events FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TABLE workflow_template_validation_events (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, workflow_template_version_id bigint NOT NULL REFERENCES workflow_template_versions(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 action text NOT NULL, attorney_user_id bigint NOT NULL REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT, reason text,
 occurred_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT workflow_validation_action_check CHECK(action IN ('validated','withdrawn')),
 CONSTRAINT workflow_validation_reason_check CHECK(action<>'withdrawn' OR (reason IS NOT NULL AND btrim(reason)<>''))
);
CREATE INDEX workflow_validation_version_idx ON workflow_template_validation_events(workflow_template_version_id,occurred_at DESC,id DESC);
CREATE INDEX workflow_validation_attorney_idx ON workflow_template_validation_events(attorney_user_id);
CREATE TRIGGER workflow_validation_immutable BEFORE UPDATE OR DELETE ON workflow_template_validation_events FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TABLE task_assignment_events (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint NOT NULL, task_id bigint NOT NULL,
 previous_user_id bigint REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT, new_user_id bigint REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 actor_user_id bigint REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT, origin text NOT NULL, reason text, occurred_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT task_assignment_events_matter_id_id_key UNIQUE(matter_id,id),
 CONSTRAINT task_assignment_events_task_fkey FOREIGN KEY(matter_id,task_id) REFERENCES tasks(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT task_assignment_events_change_check CHECK((previous_user_id IS NOT NULL OR new_user_id IS NOT NULL) AND previous_user_id IS DISTINCT FROM new_user_id),
 CONSTRAINT task_assignment_events_origin_check CHECK(origin IN ('user','system') AND (origin<>'user' OR actor_user_id IS NOT NULL))
);
CREATE INDEX task_assignment_events_task_idx ON task_assignment_events(matter_id,task_id,occurred_at DESC,id DESC);
CREATE INDEX task_assignment_events_previous_idx ON task_assignment_events(previous_user_id);
CREATE INDEX task_assignment_events_new_idx ON task_assignment_events(new_user_id);
CREATE INDEX task_assignment_events_actor_idx ON task_assignment_events(actor_user_id);
CREATE TRIGGER task_assignment_events_immutable BEFORE UPDATE OR DELETE ON task_assignment_events FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TABLE deadline_assignment_events (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint NOT NULL, deadline_id bigint NOT NULL,
 previous_user_id bigint REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT, new_user_id bigint REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 actor_user_id bigint REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT, origin text NOT NULL, reason text, occurred_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT deadline_assignment_events_matter_id_id_key UNIQUE(matter_id,id),
 CONSTRAINT deadline_assignment_events_deadline_fkey FOREIGN KEY(matter_id,deadline_id) REFERENCES deadlines(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT deadline_assignment_events_change_check CHECK((previous_user_id IS NOT NULL OR new_user_id IS NOT NULL) AND previous_user_id IS DISTINCT FROM new_user_id),
 CONSTRAINT deadline_assignment_events_origin_check CHECK(origin IN ('user','system') AND (origin<>'user' OR actor_user_id IS NOT NULL))
);
CREATE INDEX deadline_assignment_events_deadline_idx ON deadline_assignment_events(matter_id,deadline_id,occurred_at DESC,id DESC);
CREATE INDEX deadline_assignment_events_previous_idx ON deadline_assignment_events(previous_user_id);
CREATE INDEX deadline_assignment_events_new_idx ON deadline_assignment_events(new_user_id);
CREATE INDEX deadline_assignment_events_actor_idx ON deadline_assignment_events(actor_user_id);
CREATE TRIGGER deadline_assignment_events_immutable BEFORE UPDATE OR DELETE ON deadline_assignment_events FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TABLE task_assignment_notification_items (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint NOT NULL, notification_id bigint NOT NULL, task_id bigint NOT NULL, assignment_event_id bigint NOT NULL, created_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT task_notice_unique UNIQUE(notification_id,task_id,assignment_event_id),
 CONSTRAINT task_notice_notification_fk FOREIGN KEY(matter_id,notification_id) REFERENCES notifications(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT task_notice_task_fk FOREIGN KEY(matter_id,task_id) REFERENCES tasks(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT task_notice_assignment_fk FOREIGN KEY(matter_id,assignment_event_id) REFERENCES task_assignment_events(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT
);
CREATE INDEX task_notice_notification_idx ON task_assignment_notification_items(matter_id,notification_id);
CREATE INDEX task_notice_task_idx ON task_assignment_notification_items(matter_id,task_id);
CREATE INDEX task_notice_assignment_idx ON task_assignment_notification_items(matter_id,assignment_event_id);
CREATE TABLE deadline_assignment_notification_items (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint NOT NULL, notification_id bigint NOT NULL, deadline_id bigint NOT NULL, assignment_event_id bigint NOT NULL, created_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT deadline_notice_unique UNIQUE(notification_id,deadline_id,assignment_event_id),
 CONSTRAINT deadline_notice_notification_fk FOREIGN KEY(matter_id,notification_id) REFERENCES notifications(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT deadline_notice_deadline_fk FOREIGN KEY(matter_id,deadline_id) REFERENCES deadlines(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT deadline_notice_assignment_fk FOREIGN KEY(matter_id,assignment_event_id) REFERENCES deadline_assignment_events(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT
);
CREATE INDEX deadline_notice_notification_idx ON deadline_assignment_notification_items(matter_id,notification_id);
CREATE INDEX deadline_notice_deadline_idx ON deadline_assignment_notification_items(matter_id,deadline_id);
CREATE INDEX deadline_notice_assignment_idx ON deadline_assignment_notification_items(matter_id,assignment_event_id);

CREATE TABLE task_events (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint NOT NULL, task_id bigint NOT NULL, event_type text NOT NULL, old_value text, new_value text, reason text, actual_on date, is_historical boolean NOT NULL DEFAULT false, actor_user_id bigint NOT NULL REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT, occurred_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT task_parent_fk FOREIGN KEY(matter_id,task_id) REFERENCES tasks(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT task_event_check CHECK(event_type IN ('created','status_changed','assignment_changed','required_changed','applicability_changed','reopened','canceled','historical_completion') AND (event_type NOT IN ('required_changed','reopened','canceled') OR (reason IS NOT NULL AND btrim(reason)<>'')) AND (event_type<>'historical_completion' OR is_historical))
);
CREATE INDEX task_parent_idx ON task_events(matter_id,task_id,occurred_at DESC,id DESC);
CREATE INDEX task_actor_idx ON task_events(actor_user_id);
CREATE TRIGGER task_immutable BEFORE UPDATE OR DELETE ON task_events FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();

CREATE TABLE task_dependency_events (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint NOT NULL, task_dependency_id bigint NOT NULL, event_type text NOT NULL, reason text NOT NULL, actor_user_id bigint REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT, occurred_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT task_dep_parent_fk FOREIGN KEY(matter_id,task_dependency_id) REFERENCES task_dependencies(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT task_dep_event_check CHECK(event_type IN ('review_required','resolved','reactivated') AND btrim(reason)<>'' AND (event_type='review_required' OR actor_user_id IS NOT NULL))
);
CREATE INDEX task_dep_parent_idx ON task_dependency_events(matter_id,task_dependency_id,occurred_at DESC,id DESC);
CREATE INDEX task_dep_actor_idx ON task_dependency_events(actor_user_id);
CREATE TRIGGER task_dep_immutable BEFORE UPDATE OR DELETE ON task_dependency_events FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();

CREATE TABLE requirement_events (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint NOT NULL, requirement_id bigint NOT NULL, event_type text NOT NULL, old_value text, new_value text, reason text, origin text NOT NULL, actor_user_id bigint REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT, occurred_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT requirement_parent_fk FOREIGN KEY(matter_id,requirement_id) REFERENCES matter_requirements(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT requirement_event_check CHECK(event_type IN ('created','status_changed','required_changed','nonwaivable_changed','applicability_changed','canceled','reopened') AND origin IN ('user','system') AND (origin<>'user' OR actor_user_id IS NOT NULL) AND (event_type NOT IN ('required_changed','nonwaivable_changed','canceled','reopened') OR (reason IS NOT NULL AND btrim(reason)<>'')))
);
CREATE INDEX requirement_parent_idx ON requirement_events(matter_id,requirement_id,occurred_at DESC,id DESC);
CREATE INDEX requirement_actor_idx ON requirement_events(actor_user_id);
CREATE TRIGGER requirement_immutable BEFORE UPDATE OR DELETE ON requirement_events FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();

CREATE TABLE document_status_events (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint NOT NULL, document_id bigint NOT NULL, status text NOT NULL, note text, actor_user_id bigint NOT NULL REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT, occurred_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT doc_status_parent_fk FOREIGN KEY(matter_id,document_id) REFERENCES documents(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT doc_status_event_check CHECK(status IN ('requested','received','awaiting_signature','signed','rejected','unavailable','other'))
);
CREATE INDEX doc_status_parent_idx ON document_status_events(matter_id,document_id,occurred_at DESC,id DESC);
CREATE INDEX doc_status_actor_idx ON document_status_events(actor_user_id);
CREATE TRIGGER doc_status_immutable BEFORE UPDATE OR DELETE ON document_status_events FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();

CREATE TABLE document_access_events (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint NOT NULL, document_version_id bigint NOT NULL, action text NOT NULL, actor_user_id bigint NOT NULL REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT, occurred_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT doc_access_parent_fk FOREIGN KEY(matter_id,document_version_id) REFERENCES document_versions(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT doc_access_event_check CHECK(action IN ('external_link_open_authorized','s3_link_issued','access_denied'))
);
CREATE INDEX doc_access_parent_idx ON document_access_events(matter_id,document_version_id,occurred_at DESC,id DESC);
CREATE INDEX doc_access_actor_idx ON document_access_events(actor_user_id);
CREATE TRIGGER doc_access_immutable BEFORE UPDATE OR DELETE ON document_access_events FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();

CREATE TABLE approval_request_events (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint NOT NULL, approval_request_id bigint NOT NULL, event_type text NOT NULL, reason text, actor_user_id bigint NOT NULL REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT, occurred_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT approval_req_parent_fk FOREIGN KEY(matter_id,approval_request_id) REFERENCES approval_requests(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT approval_req_event_check CHECK(event_type IN ('submitted','withdrawn') AND (event_type<>'withdrawn' OR (reason IS NOT NULL AND btrim(reason)<>'')))
);
CREATE INDEX approval_req_parent_idx ON approval_request_events(matter_id,approval_request_id,occurred_at DESC,id DESC);
CREATE INDEX approval_req_actor_idx ON approval_request_events(actor_user_id);
CREATE TRIGGER approval_req_immutable BEFORE UPDATE OR DELETE ON approval_request_events FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();

CREATE TABLE exception_lifecycle_events (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint NOT NULL, exception_request_id bigint NOT NULL, event_type text NOT NULL, reason text NOT NULL, actor_user_id bigint REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT, occurred_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT exception_life_parent_fk FOREIGN KEY(matter_id,exception_request_id) REFERENCES exception_requests(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT exception_life_event_check CHECK(event_type IN ('withdrawn','no_longer_needed','review_required','revoked') AND btrim(reason)<>'' AND (event_type='review_required' OR actor_user_id IS NOT NULL))
);
CREATE INDEX exception_life_parent_idx ON exception_lifecycle_events(matter_id,exception_request_id,occurred_at DESC,id DESC);
CREATE INDEX exception_life_actor_idx ON exception_lifecycle_events(actor_user_id);
CREATE TRIGGER exception_life_immutable BEFORE UPDATE OR DELETE ON exception_lifecycle_events FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
ALTER TABLE task_assignment_events ADD CONSTRAINT task_assignment_matter_id_task_key UNIQUE(matter_id,id,task_id);
ALTER TABLE task_assignment_notification_items ADD CONSTRAINT task_notice_event_task_fk FOREIGN KEY(matter_id,assignment_event_id,task_id) REFERENCES task_assignment_events(matter_id,id,task_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE deadline_assignment_events ADD CONSTRAINT deadline_assignment_matter_id_deadline_key UNIQUE(matter_id,id,deadline_id);
ALTER TABLE deadline_assignment_notification_items ADD CONSTRAINT deadline_notice_event_deadline_fk FOREIGN KEY(matter_id,assignment_event_id,deadline_id) REFERENCES deadline_assignment_events(matter_id,id,deadline_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
CREATE INDEX task_notice_event_task_idx ON task_assignment_notification_items(matter_id,assignment_event_id,task_id);
CREATE INDEX deadline_notice_event_deadline_idx ON deadline_assignment_notification_items(matter_id,assignment_event_id,deadline_id);
