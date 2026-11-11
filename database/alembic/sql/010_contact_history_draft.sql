-- Proposed contact classification/history tables; not a production migration.
CREATE TABLE party_roles (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, code text NOT NULL UNIQUE, label text NOT NULL,
 is_active boolean NOT NULL DEFAULT true, created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT party_roles_nonblank_check CHECK(btrim(code)<>'' AND btrim(label)<>'')
);
CREATE TRIGGER party_roles_updated BEFORE UPDATE ON party_roles FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TABLE reference_label_events (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, document_category_id bigint REFERENCES document_categories(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 deadline_type_id bigint REFERENCES deadline_types(id) ON UPDATE RESTRICT ON DELETE RESTRICT, party_role_id bigint REFERENCES party_roles(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 action text NOT NULL, old_label text, new_label text, actor_user_id bigint NOT NULL REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 occurred_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT reference_label_events_target_check CHECK(num_nonnulls(document_category_id,deadline_type_id,party_role_id)=1),
 CONSTRAINT reference_label_events_action_check CHECK(action IN ('created','renamed','retired','reactivated'))
);
CREATE INDEX reference_labels_category_idx ON reference_label_events(document_category_id,occurred_at DESC,id DESC);
CREATE INDEX reference_labels_deadline_idx ON reference_label_events(deadline_type_id,occurred_at DESC,id DESC);
CREATE INDEX reference_labels_role_idx ON reference_label_events(party_role_id,occurred_at DESC,id DESC);
CREATE INDEX reference_labels_actor_idx ON reference_label_events(actor_user_id);
CREATE TRIGGER reference_labels_immutable BEFORE UPDATE OR DELETE ON reference_label_events FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TABLE matter_legacy_references (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint NOT NULL REFERENCES matters(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 label text NOT NULL, reference text NOT NULL, created_by bigint NOT NULL REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 created_at timestamptz NOT NULL DEFAULT now(), CONSTRAINT matter_legacy_references_nonblank CHECK(btrim(label)<>'' AND btrim(reference)<>'')
);
CREATE INDEX matter_legacy_references_matter_idx ON matter_legacy_references(matter_id);
CREATE INDEX matter_legacy_references_creator_idx ON matter_legacy_references(created_by);
CREATE TABLE contact_organization_relationships (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, person_contact_id bigint NOT NULL REFERENCES contacts(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 organization_contact_id bigint NOT NULL REFERENCES contacts(id) ON UPDATE RESTRICT ON DELETE RESTRICT, title text, started_on date, ended_on date,
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT contact_org_distinct_check CHECK(person_contact_id<>organization_contact_id),
 CONSTRAINT contact_org_dates_check CHECK(started_on IS NULL OR ended_on IS NULL OR ended_on>=started_on)
);
CREATE INDEX contact_org_person_idx ON contact_organization_relationships(person_contact_id);
CREATE INDEX contact_org_organization_idx ON contact_organization_relationships(organization_contact_id);
CREATE UNIQUE INDEX contact_org_active_key ON contact_organization_relationships(person_contact_id,organization_contact_id) WHERE ended_on IS NULL;
CREATE TRIGGER contact_org_updated BEFORE UPDATE ON contact_organization_relationships FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TABLE matter_party_roles (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint NOT NULL, matter_party_id bigint NOT NULL,
 party_role_id bigint NOT NULL REFERENCES party_roles(id) ON UPDATE RESTRICT ON DELETE RESTRICT, other_description text,
 assigned_by bigint NOT NULL REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT, created_at timestamptz NOT NULL DEFAULT now(), ended_at timestamptz,
 CONSTRAINT matter_party_roles_party_fkey FOREIGN KEY(matter_id,matter_party_id) REFERENCES matter_parties(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT matter_party_roles_end_check CHECK(ended_at IS NULL OR ended_at>=created_at)
);
CREATE INDEX matter_party_roles_party_idx ON matter_party_roles(matter_id,matter_party_id);
CREATE INDEX matter_party_roles_role_idx ON matter_party_roles(party_role_id);
CREATE INDEX matter_party_roles_actor_idx ON matter_party_roles(assigned_by);
-- 'Other' uniqueness and classification history remain a service design decision.
CREATE TABLE contact_merges (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, source_contact_id bigint NOT NULL REFERENCES contacts(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 target_contact_id bigint NOT NULL REFERENCES contacts(id) ON UPDATE RESTRICT ON DELETE RESTRICT, status text NOT NULL,
 performed_by bigint NOT NULL REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT, performed_at timestamptz NOT NULL DEFAULT now(), resolution jsonb NOT NULL, reason text,
 CONSTRAINT contact_merges_distinct_check CHECK(source_contact_id<>target_contact_id),
 CONSTRAINT contact_merges_status_check CHECK(status IN ('completed','correction_required','corrected'))
);
CREATE INDEX contact_merges_source_idx ON contact_merges(source_contact_id);
CREATE INDEX contact_merges_target_idx ON contact_merges(target_contact_id);
CREATE INDEX contact_merges_actor_idx ON contact_merges(performed_by);
CREATE TABLE contact_merge_items (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, contact_merge_id bigint NOT NULL REFERENCES contact_merges(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 matter_id bigint REFERENCES matters(id) ON UPDATE RESTRICT ON DELETE RESTRICT, item_type text NOT NULL, source_id bigint NOT NULL, target_id bigint,
 recorded_at timestamptz NOT NULL DEFAULT now(), CONSTRAINT contact_merge_items_type_check CHECK(btrim(item_type)<>'')
);
CREATE INDEX contact_merge_items_merge_idx ON contact_merge_items(contact_merge_id);
CREATE INDEX contact_merge_items_matter_idx ON contact_merge_items(matter_id);
CREATE TRIGGER contact_merge_items_immutable BEFORE UPDATE OR DELETE ON contact_merge_items FOR EACH ROW EXECUTE FUNCTION reject_row_mutation();
CREATE TABLE matter_party_organization_snapshots (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint NOT NULL, matter_party_snapshot_id bigint NOT NULL,
 organization_contact_id bigint REFERENCES contacts(id) ON UPDATE RESTRICT ON DELETE RESTRICT, organization_name text NOT NULL,
 relationship_label text, recorded_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT party_org_snapshots_parent_fkey FOREIGN KEY(matter_id,matter_party_snapshot_id) REFERENCES matter_party_snapshots(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT party_org_snapshots_name_check CHECK(btrim(organization_name)<>'')
);
CREATE INDEX party_org_snapshots_parent_idx ON matter_party_organization_snapshots(matter_id,matter_party_snapshot_id);
CREATE INDEX party_org_snapshots_contact_idx ON matter_party_organization_snapshots(organization_contact_id);
CREATE FUNCTION protect_party_organization_snapshot() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE parent_seal timestamptz;
BEGIN
 IF TG_OP <> 'INSERT' THEN RAISE EXCEPTION 'snapshot children cannot be changed or deleted'; END IF;
 SELECT sealed_at INTO parent_seal FROM matter_party_snapshots WHERE matter_id=NEW.matter_id AND id=NEW.matter_party_snapshot_id FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'snapshot does not exist' USING ERRCODE='23503'; END IF;
 IF parent_seal IS NOT NULL THEN RAISE EXCEPTION 'cannot add children to a sealed snapshot'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER party_org_snapshots_protect BEFORE INSERT OR UPDATE OR DELETE ON matter_party_organization_snapshots FOR EACH ROW EXECUTE FUNCTION protect_party_organization_snapshot();
