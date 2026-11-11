-- Draft hardening for disposable PostgreSQL 16+; not an Alembic migration.
-- Evaluation/send and children must be created and sealed in the same transaction.
ALTER TABLE readiness_evaluations ADD COLUMN sealed_at timestamptz;
ALTER TABLE correspondence_sends ADD COLUMN sealed_at timestamptz;
DROP TRIGGER readiness_evaluations_immutable ON readiness_evaluations;
DROP TRIGGER correspondence_sends_immutable ON correspondence_sends;
CREATE TRIGGER readiness_evaluations_seal BEFORE INSERT OR UPDATE OR DELETE ON readiness_evaluations FOR EACH ROW EXECUTE FUNCTION protect_snapshot_header();
CREATE TRIGGER correspondence_sends_seal BEFORE INSERT OR UPDATE OR DELETE ON correspondence_sends FOR EACH ROW EXECUTE FUNCTION protect_snapshot_header();

-- At commit check the current row, so an inserted-then-sealed aggregate succeeds.
CREATE FUNCTION require_sealed_aggregate_at_commit() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE current_seal timestamptz;
BEGIN
 IF TG_TABLE_NAME='readiness_evaluations' THEN
  SELECT sealed_at INTO current_seal FROM readiness_evaluations WHERE id=NEW.id;
 ELSE
  SELECT sealed_at INTO current_seal FROM correspondence_sends WHERE id=NEW.id;
 END IF;
 IF FOUND AND current_seal IS NULL THEN RAISE EXCEPTION '% must be sealed before commit', TG_TABLE_NAME; END IF;
 RETURN NULL;
END $$;
CREATE CONSTRAINT TRIGGER readiness_evaluations_sealed_commit AFTER INSERT OR UPDATE ON readiness_evaluations DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION require_sealed_aggregate_at_commit();
CREATE CONSTRAINT TRIGGER correspondence_sends_sealed_commit AFTER INSERT OR UPDATE ON correspondence_sends DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION require_sealed_aggregate_at_commit();

-- All child inserts lock the same aggregate row as sealing. Updates/deletes are
-- already rejected by immutable triggers; triggers below only admit new children.
CREATE FUNCTION require_open_readiness_for_item() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE parent_seal timestamptz;
BEGIN
 SELECT sealed_at INTO parent_seal FROM readiness_evaluations WHERE matter_id=NEW.matter_id AND id=NEW.readiness_evaluation_id FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'readiness evaluation missing' USING ERRCODE='23503'; END IF;
 IF parent_seal IS NOT NULL THEN RAISE EXCEPTION 'readiness evaluation is sealed'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER readiness_items_open_parent BEFORE INSERT ON readiness_evaluation_items FOR EACH ROW EXECUTE FUNCTION require_open_readiness_for_item();
CREATE FUNCTION require_open_readiness_for_source() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE parent_seal timestamptz;
BEGIN
 SELECT e.sealed_at INTO parent_seal FROM readiness_evaluation_items i JOIN readiness_evaluations e ON (e.matter_id,e.id)=(i.matter_id,i.readiness_evaluation_id)
 WHERE i.matter_id=NEW.matter_id AND i.id=NEW.readiness_evaluation_item_id FOR UPDATE OF e;
 IF NOT FOUND THEN RAISE EXCEPTION 'readiness item missing' USING ERRCODE='23503'; END IF;
 IF parent_seal IS NOT NULL THEN RAISE EXCEPTION 'readiness evaluation is sealed'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER readiness_sources_open_parent BEFORE INSERT ON readiness_evaluation_item_sources FOR EACH ROW EXECUTE FUNCTION require_open_readiness_for_source();
CREATE FUNCTION require_open_send_for_child() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE parent_seal timestamptz;
BEGIN
 SELECT sealed_at INTO parent_seal FROM correspondence_sends WHERE matter_id=NEW.matter_id AND id=NEW.send_id FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'send missing' USING ERRCODE='23503'; END IF;
 IF parent_seal IS NOT NULL THEN RAISE EXCEPTION 'send is sealed'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER send_recipients_open_parent BEFORE INSERT ON correspondence_send_recipients FOR EACH ROW EXECUTE FUNCTION require_open_send_for_child();
CREATE TRIGGER send_evidence_open_parent BEFORE INSERT ON correspondence_send_evidence FOR EACH ROW EXECUTE FUNCTION require_open_send_for_child();

-- Validation event must be from the same version, including when null.
ALTER TABLE workflow_template_validation_events ADD CONSTRAINT workflow_validation_version_id_key UNIQUE(workflow_template_version_id,id);
ALTER TABLE readiness_evaluations ADD CONSTRAINT readiness_evaluations_validation_version_fkey FOREIGN KEY(workflow_template_version_id,template_validation_event_id) REFERENCES workflow_template_validation_events(workflow_template_version_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT;
CREATE INDEX readiness_evaluations_validation_version_idx ON readiness_evaluations(workflow_template_version_id,template_validation_event_id);

CREATE FUNCTION validate_closing_readiness_record() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE evaluation_result text; evaluation_purpose text; evaluation_seal timestamptz; closing_type text;
BEGIN
 SELECT result,purpose,sealed_at INTO evaluation_result,evaluation_purpose,evaluation_seal FROM readiness_evaluations
  WHERE matter_id=NEW.matter_id AND id=NEW.readiness_evaluation_id FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'readiness evaluation missing' USING ERRCODE='23503'; END IF;
 SELECT event_type INTO closing_type FROM closing_events WHERE matter_id=NEW.matter_id AND id=NEW.closing_event_id;
 IF NOT FOUND THEN RAISE EXCEPTION 'closing event missing' USING ERRCODE='23503'; END IF;
 IF evaluation_seal IS NULL OR evaluation_purpose <> 'transaction_closing' OR closing_type <> 'closed' THEN
  RAISE EXCEPTION 'closing requires a sealed transaction-closing evaluation and closed event';
 END IF;
 IF evaluation_result='not_ready' AND (NEW.not_ready_reason IS NULL OR btrim(NEW.not_ready_reason)='') THEN
  RAISE EXCEPTION 'a not-ready closing requires a reason';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER closing_readiness_validate BEFORE INSERT ON closing_readiness_records FOR EACH ROW EXECUTE FUNCTION validate_closing_readiness_record();
