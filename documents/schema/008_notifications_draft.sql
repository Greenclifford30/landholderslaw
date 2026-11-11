-- Draft: scheduling, authorization, and provider outcomes require transactional services.
CREATE TABLE firm_settings (
 id smallint PRIMARY KEY DEFAULT 1 CHECK(id=1), timezone text NOT NULL DEFAULT 'America/Chicago', reminder_time time NOT NULL DEFAULT '09:00',
 historical_cutoff_on date, updated_by bigint REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 updated_at timestamptz NOT NULL DEFAULT now(), row_version bigint NOT NULL DEFAULT 1,
 CONSTRAINT firm_settings_timezone_check CHECK(btrim(timezone)<>''), CONSTRAINT firm_settings_version_check CHECK(row_version>0)
);
CREATE INDEX firm_settings_updated_by_idx ON firm_settings(updated_by);
CREATE TRIGGER firm_settings_updated BEFORE UPDATE ON firm_settings FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TABLE firm_holidays (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, holiday_on date NOT NULL UNIQUE, name text NOT NULL,
 created_by bigint NOT NULL REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT, created_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT firm_holidays_name_check CHECK(btrim(name)<>'')
);
CREATE INDEX firm_holidays_created_by_idx ON firm_holidays(created_by);
CREATE TABLE reminder_intervals (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, days_before integer NOT NULL UNIQUE CHECK(days_before>0),
 is_active boolean NOT NULL DEFAULT true, created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE deadline_reminder_recipients (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint NOT NULL, deadline_id bigint NOT NULL,
 user_id bigint NOT NULL REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT, is_active boolean NOT NULL DEFAULT true,
 created_by bigint NOT NULL REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT, created_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT deadline_recipients_deadline_fkey FOREIGN KEY(matter_id,deadline_id) REFERENCES deadlines(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT deadline_recipients_deadline_user_key UNIQUE(deadline_id,user_id)
);
CREATE INDEX deadline_recipients_deadline_idx ON deadline_reminder_recipients(matter_id,deadline_id);
CREATE INDEX deadline_recipients_user_idx ON deadline_reminder_recipients(user_id,is_active);
CREATE INDEX deadline_recipients_creator_idx ON deadline_reminder_recipients(created_by);
CREATE TABLE reminder_occurrences (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, matter_id bigint NOT NULL, deadline_id bigint NOT NULL, deadline_revision_id bigint NOT NULL,
 recipient_user_id bigint NOT NULL REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT, channel text NOT NULL, local_on date NOT NULL,
 scheduled_at timestamptz NOT NULL, status text NOT NULL, created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), row_version bigint NOT NULL DEFAULT 1,
 CONSTRAINT reminder_occurrences_matter_id_id_key UNIQUE(matter_id,id),
 CONSTRAINT reminder_occurrences_daily_key UNIQUE(deadline_id,recipient_user_id,channel,local_on),
 CONSTRAINT reminder_occurrences_deadline_fkey FOREIGN KEY(matter_id,deadline_id) REFERENCES deadlines(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT reminder_occurrences_revision_fkey FOREIGN KEY(deadline_id,deadline_revision_id) REFERENCES deadline_revisions(deadline_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT reminder_occurrences_channel_check CHECK(channel IN ('email','in_app')),
 CONSTRAINT reminder_occurrences_status_check CHECK(status IN ('queued','sending','sent','suppressed','failed','uncertain')),
 CONSTRAINT reminder_occurrences_version_check CHECK(row_version>0)
);
CREATE INDEX reminder_occurrences_deadline_idx ON reminder_occurrences(matter_id,deadline_id);
CREATE INDEX reminder_occurrences_revision_idx ON reminder_occurrences(deadline_id,deadline_revision_id);
CREATE INDEX reminder_occurrences_recipient_idx ON reminder_occurrences(recipient_user_id);
CREATE INDEX reminder_occurrences_queue_idx ON reminder_occurrences(status,scheduled_at);
CREATE TRIGGER reminder_occurrences_updated BEFORE UPDATE ON reminder_occurrences FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TABLE reminder_occurrence_reasons (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, reminder_occurrence_id bigint NOT NULL REFERENCES reminder_occurrences(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 kind text NOT NULL, days_before integer,
 CONSTRAINT reminder_reasons_unique UNIQUE NULLS NOT DISTINCT(reminder_occurrence_id,kind,days_before),
 CONSTRAINT reminder_reasons_kind_check CHECK((kind='advance' AND days_before IS NOT NULL AND days_before>0) OR (kind='overdue' AND days_before IS NULL))
);
CREATE TABLE delivery_attempts (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, reminder_occurrence_id bigint NOT NULL REFERENCES reminder_occurrences(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 attempt_number integer NOT NULL, provider text NOT NULL, provider_message_id text, status text NOT NULL, error_code text, started_at timestamptz NOT NULL, finished_at timestamptz,
 CONSTRAINT delivery_attempts_occurrence_number_key UNIQUE(reminder_occurrence_id,attempt_number),
 CONSTRAINT delivery_attempts_number_check CHECK(attempt_number>0), CONSTRAINT delivery_attempts_provider_check CHECK(provider IN ('ses','internal')),
 CONSTRAINT delivery_attempts_status_check CHECK(status IN ('started','accepted','delivered','failed','uncertain')),
 CONSTRAINT delivery_attempts_time_check CHECK(finished_at IS NULL OR finished_at>=started_at)
);
-- Mutable attempt state is provisional; production requires append-only provider outcome events.
CREATE TABLE notifications (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, public_id uuid NOT NULL UNIQUE, matter_id bigint NOT NULL,
 recipient_user_id bigint NOT NULL REFERENCES users(id) ON UPDATE RESTRICT ON DELETE RESTRICT, reminder_occurrence_id bigint, kind text NOT NULL,
 created_at timestamptz NOT NULL DEFAULT now(), seen_at timestamptz,
 CONSTRAINT notifications_matter_id_id_key UNIQUE(matter_id,id), CONSTRAINT notifications_occurrence_key UNIQUE(reminder_occurrence_id),
 CONSTRAINT notifications_matter_fkey FOREIGN KEY(matter_id) REFERENCES matters(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT notifications_occurrence_fkey FOREIGN KEY(matter_id,reminder_occurrence_id) REFERENCES reminder_occurrences(matter_id,id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT notifications_kind_check CHECK(btrim(kind)<>'')
);
CREATE INDEX notifications_matter_idx ON notifications(matter_id);
CREATE INDEX notifications_occurrence_idx ON notifications(matter_id,reminder_occurrence_id);
CREATE INDEX notifications_recipient_idx ON notifications(recipient_user_id,created_at DESC,id DESC);
