-- Draft hardening: proposal target sets and correspondence packages are sealed
-- within the creation transaction. This does not implement authorization.
ALTER TABLE exception_revisions ADD COLUMN sealed_at timestamptz;
DROP TRIGGER exception_revisions_immutable ON exception_revisions;
CREATE TRIGGER exception_revisions_seal BEFORE INSERT OR UPDATE OR DELETE ON exception_revisions FOR EACH ROW EXECUTE FUNCTION protect_snapshot_header();

CREATE FUNCTION require_sealed_review_package_at_commit() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE current_seal timestamptz;
BEGIN
 IF TG_TABLE_NAME='exception_revisions' THEN
  SELECT sealed_at INTO current_seal FROM exception_revisions WHERE id=NEW.id;
 ELSE
  SELECT sealed_at INTO current_seal FROM correspondence_drafts WHERE id=NEW.id;
 END IF;
 IF FOUND AND current_seal IS NULL THEN RAISE EXCEPTION '% must be sealed before commit', TG_TABLE_NAME; END IF;
 RETURN NULL;
END $$;
CREATE CONSTRAINT TRIGGER exception_revisions_sealed_commit AFTER INSERT OR UPDATE ON exception_revisions DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION require_sealed_review_package_at_commit();
CREATE CONSTRAINT TRIGGER correspondence_drafts_sealed_commit AFTER INSERT OR UPDATE ON correspondence_drafts DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION require_sealed_review_package_at_commit();

CREATE FUNCTION protect_exception_revision_child() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE parent_seal timestamptz;
BEGIN
 IF TG_OP <> 'INSERT' THEN RAISE EXCEPTION 'exception revision children cannot be changed or deleted'; END IF;
 SELECT sealed_at INTO parent_seal FROM exception_revisions WHERE matter_id=NEW.matter_id AND id=NEW.exception_revision_id FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'exception revision missing' USING ERRCODE='23503'; END IF;
 IF parent_seal IS NOT NULL THEN RAISE EXCEPTION 'exception revision is sealed'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER exception_targets_protect BEFORE INSERT OR UPDATE OR DELETE ON exception_targets FOR EACH ROW EXECUTE FUNCTION protect_exception_revision_child();
CREATE TRIGGER exception_triggers_protect BEFORE INSERT OR UPDATE OR DELETE ON exception_triggers FOR EACH ROW EXECUTE FUNCTION protect_exception_revision_child();

CREATE FUNCTION validate_exception_submission() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE parent_seal timestamptz; request_kind text; target_count bigint; invalid_count bigint;
BEGIN
 IF NEW.exception_revision_id IS NULL THEN RETURN NEW; END IF;
 SELECT er.sealed_at, req.kind INTO parent_seal, request_kind
 FROM exception_revisions er JOIN exception_requests req ON (req.matter_id,req.id)=(er.matter_id,er.exception_request_id)
 WHERE er.matter_id=NEW.matter_id AND er.id=NEW.exception_revision_id FOR UPDATE OF er;
 IF NOT FOUND THEN RAISE EXCEPTION 'exception revision missing' USING ERRCODE='23503'; END IF;
 IF parent_seal IS NULL THEN RAISE EXCEPTION 'exception revision must be sealed before review'; END IF;
 SELECT count(*), count(*) FILTER (WHERE (request_kind='task_waiver' AND task_id IS NULL) OR (request_kind='closing_override' AND requirement_id IS NULL))
 INTO target_count,invalid_count FROM exception_targets WHERE matter_id=NEW.matter_id AND exception_revision_id=NEW.exception_revision_id;
 IF invalid_count<>0 OR (request_kind='task_waiver' AND target_count<>1) OR (request_kind='closing_override' AND target_count<1) THEN
  RAISE EXCEPTION 'exception targets do not match request kind';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER approval_requests_exception_validate BEFORE INSERT OR UPDATE ON approval_requests FOR EACH ROW EXECUTE FUNCTION validate_exception_submission();
-- A review round always refers to the same immutable target and requester.
CREATE FUNCTION protect_approval_request_identity() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF TG_OP='DELETE' THEN RAISE EXCEPTION 'approval requests cannot be deleted'; END IF;
 IF (NEW.id,NEW.public_id,NEW.matter_id,NEW.draft_id,NEW.exception_revision_id,NEW.requested_by,NEW.requested_at)
 IS DISTINCT FROM (OLD.id,OLD.public_id,OLD.matter_id,OLD.draft_id,OLD.exception_revision_id,OLD.requested_by,OLD.requested_at) THEN
  RAISE EXCEPTION 'approval request target and requester are immutable';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER approval_requests_protect_identity BEFORE UPDATE OR DELETE ON approval_requests FOR EACH ROW EXECUTE FUNCTION protect_approval_request_identity();
