"use client";

import {
  BellRing,
  Building2,
  Check,
  ChevronRight,
  CircleUserRound,
  Clock3,
  LockKeyhole,
  RotateCcw,
  ShieldCheck,
} from "lucide-react";
import { FormEvent, KeyboardEvent, useMemo, useState } from "react";

type SettingsSection = "firm" | "notifications" | "security";

type FirmSettings = {
  firmName: string;
  replyTo: string;
  timezone: string;
  defaultOwner: string;
  reminderWindow: string;
};

const initialFirmSettings: FirmSettings = {
  firmName: "Landholders Law",
  replyTo: "operations@landholderslaw.com",
  timezone: "America/Chicago",
  defaultOwner: "Jordan Lee",
  reminderWindow: "3",
};

const sections = [
  { id: "firm", label: "Firm & workflow", detail: "Identity and matter defaults", icon: Building2 },
  { id: "notifications", label: "Notifications", detail: "Deadline and approval alerts", icon: BellRing },
  { id: "security", label: "Access & security", detail: "Role and sign-in controls", icon: LockKeyhole },
] satisfies Array<{ id: SettingsSection; label: string; detail: string; icon: typeof Building2 }>;

export function SettingsClient() {
  const [section, setSection] = useState<SettingsSection>("firm");
  const [firmSettings, setFirmSettings] = useState(initialFirmSettings);
  const [savedFirmSettings, setSavedFirmSettings] = useState(initialFirmSettings);
  const [savedMessage, setSavedMessage] = useState("");
  const [deadlineAlerts, setDeadlineAlerts] = useState(true);
  const [approvalAlerts, setApprovalAlerts] = useState(true);
  const [dailyDigest, setDailyDigest] = useState(false);

  const isDirty = useMemo(
    () => JSON.stringify(firmSettings) !== JSON.stringify(savedFirmSettings),
    [firmSettings, savedFirmSettings],
  );

  function updateField<Key extends keyof FirmSettings>(key: Key, value: FirmSettings[Key]) {
    setFirmSettings((current) => ({ ...current, [key]: value }));
    setSavedMessage("");
  }

  function saveFirmSettings(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setSavedFirmSettings(firmSettings);
    setSavedMessage("Mock settings saved until you leave or refresh this page.");
  }

  function resetFirmSettings() {
    setFirmSettings(savedFirmSettings);
    setSavedMessage("");
  }

  function handleCategoryKeyDown(event: KeyboardEvent<HTMLButtonElement>, index: number) {
    if (!["ArrowDown", "ArrowUp", "ArrowLeft", "ArrowRight", "Home", "End"].includes(event.key)) return;
    event.preventDefault();
    let nextIndex = index;
    if (event.key === "Home") nextIndex = 0;
    if (event.key === "End") nextIndex = sections.length - 1;
    if (event.key === "ArrowDown" || event.key === "ArrowRight") nextIndex = (index + 1) % sections.length;
    if (event.key === "ArrowUp" || event.key === "ArrowLeft") nextIndex = (index - 1 + sections.length) % sections.length;
    const nextSection = sections[nextIndex].id;
    setSection(nextSection);
    requestAnimationFrame(() => document.getElementById(`settings-tab-${nextSection}`)?.focus());
  }

  return (
    <>
      <header className="ops-page-heading">
        <div>
          <h1>Settings</h1>
          <p>Review the firm defaults that shape daily transaction work.</p>
        </div>
        <div className="ops-role-boundary">
          <CircleUserRound aria-hidden="true" size={17} />
          <span>Jordan Lee · Operations</span>
        </div>
      </header>

      <div className="ops-prototype-boundary" role="note">
        <ShieldCheck aria-hidden="true" size={18} />
        <div>
          <strong>Settings prototype</strong>
          <p>Changes are illustrative and reset when you leave or refresh this page. No account or firm record is updated.</p>
        </div>
      </div>

      <div className="ops-settings-layout">
        <div className="ops-settings-nav" role="tablist" aria-label="Settings categories" aria-orientation="vertical">
          <p>Workspace settings</p>
          {sections.map((item, index) => {
            const Icon = item.icon;
            return (
              <button
                type="button"
                role="tab"
                id={`settings-tab-${item.id}`}
                aria-controls={`settings-panel-${item.id}`}
                className={section === item.id ? "is-active" : ""}
                aria-selected={section === item.id}
                tabIndex={section === item.id ? 0 : -1}
                onClick={() => setSection(item.id)}
                onKeyDown={(event) => handleCategoryKeyDown(event, index)}
                key={item.id}
              >
                <Icon aria-hidden="true" size={18} />
                <span>
                  <strong>{item.label}</strong>
                  <small>{item.detail}</small>
                </span>
                <ChevronRight aria-hidden="true" size={16} />
              </button>
            );
          })}
          <div className="ops-settings-scope">
            <span>Prototype scope</span>
            <strong>Operations workspace</strong>
            <small>Fictional configuration</small>
          </div>
        </div>

        <div className="ops-settings-workspace" role="tabpanel" id={`settings-panel-${section}`} aria-labelledby={`settings-tab-${section}`} tabIndex={0}>
          {section === "firm" ? (
            <form onSubmit={saveFirmSettings}>
              <section className="ops-panel" aria-labelledby="firm-settings-title">
                <header className="ops-panel-heading">
                  <div>
                    <h2 id="firm-settings-title">Firm identity</h2>
                    <p>Labels shown across the internal operations workspace.</p>
                  </div>
                  <Building2 aria-hidden="true" size={20} />
                </header>
                <div className="ops-settings-form-grid">
                  <label className="ops-settings-field" htmlFor="firm-display-name">
                    <span>Firm display name</span>
                    <input id="firm-display-name" aria-label="Firm display name" value={firmSettings.firmName} onChange={(event) => updateField("firmName", event.target.value)} />
                    <small>Appears in the workspace navigation and internal records.</small>
                  </label>
                  <label className="ops-settings-field" htmlFor="operations-reply-to">
                    <span>Operations reply-to</span>
                    <input id="operations-reply-to" aria-label="Operations reply-to" type="email" value={firmSettings.replyTo} onChange={(event) => updateField("replyTo", event.target.value)} />
                    <small>Illustrative internal address for workflow notices.</small>
                  </label>
                </div>
              </section>

              <section className="ops-panel" aria-labelledby="workflow-settings-title">
                <header className="ops-panel-heading">
                  <div>
                    <h2 id="workflow-settings-title">Workflow defaults</h2>
                    <p>Starting values for new fictional matter records.</p>
                  </div>
                  <Clock3 aria-hidden="true" size={20} />
                </header>
                <div className="ops-settings-form-grid">
                  <label className="ops-settings-field" htmlFor="practice-timezone">
                    <span>Practice timezone</span>
                    <select id="practice-timezone" aria-label="Practice timezone" value={firmSettings.timezone} onChange={(event) => updateField("timezone", event.target.value)}>
                      <option value="America/Chicago">Central Time · Chicago</option>
                      <option value="America/New_York">Eastern Time</option>
                    </select>
                    <small>Controls how controlling dates are presented.</small>
                  </label>
                  <label className="ops-settings-field" htmlFor="default-owner">
                    <span>Default operations owner</span>
                    <select id="default-owner" aria-label="Default operations owner" value={firmSettings.defaultOwner} onChange={(event) => updateField("defaultOwner", event.target.value)}>
                      <option>Jordan Lee</option>
                      <option>Maya Patel</option>
                      <option>Unassigned</option>
                    </select>
                    <small>Can still be changed on an individual matter.</small>
                  </label>
                  <label className="ops-settings-field" htmlFor="deadline-window">
                    <span>Upcoming deadline window</span>
                    <select id="deadline-window" aria-label="Upcoming deadline window" value={firmSettings.reminderWindow} onChange={(event) => updateField("reminderWindow", event.target.value)}>
                      <option value="1">1 business day</option>
                      <option value="3">3 business days</option>
                      <option value="5">5 business days</option>
                    </select>
                    <small>Sets when a deadline enters the attention queue.</small>
                  </label>
                </div>
              </section>

              <div className="ops-settings-actions">
                <div aria-live="polite">
                  {savedMessage ? <span className="is-saved"><Check aria-hidden="true" size={16} />{savedMessage}</span> : isDirty ? <span>Unsaved mock changes</span> : <span>No changes to save</span>}
                </div>
                <button type="button" className="ops-secondary-button" onClick={resetFirmSettings} disabled={!isDirty}>
                  <RotateCcw aria-hidden="true" size={16} /> Reset
                </button>
                <button type="submit" className="ops-primary-button" disabled={!isDirty}>Save changes</button>
              </div>
            </form>
          ) : null}

          {section === "notifications" ? (
            <section className="ops-panel" aria-labelledby="notification-settings-title">
              <header className="ops-panel-heading">
                <div>
                  <h2 id="notification-settings-title">Notification preferences</h2>
                  <p>Choose which operational events should surface in the workspace.</p>
                </div>
                <BellRing aria-hidden="true" size={20} />
              </header>
              <div className="ops-preference-list">
                <TogglePreference label="Deadline alerts" detail="Overdue, due-today, and upcoming controlling dates." checked={deadlineAlerts} onChange={setDeadlineAlerts} />
                <TogglePreference label="Approval activity" detail="Attorney decisions and requested changes." checked={approvalAlerts} onChange={setApprovalAlerts} />
                <TogglePreference label="Daily operations digest" detail="One morning summary of open work and deadline movement." checked={dailyDigest} onChange={setDailyDigest} />
              </div>
              <div className="ops-settings-inline-note" role="status">
                <Check aria-hidden="true" size={17} /> Preference changes apply immediately to this local mock.
              </div>
            </section>
          ) : null}

          {section === "security" ? (
            <>
              <section className="ops-panel" aria-labelledby="access-settings-title">
                <header className="ops-panel-heading">
                  <div>
                    <h2 id="access-settings-title">Access profile</h2>
                    <p>Illustrative role information for the current prototype user.</p>
                  </div>
                  <LockKeyhole aria-hidden="true" size={20} />
                </header>
                <dl className="ops-access-list">
                  <div><dt>Display name</dt><dd>Jordan Lee</dd></div>
                  <div><dt>Workspace role</dt><dd>Operations</dd></div>
                  <div><dt>Decision authority</dt><dd><span className="ops-status-text is-warning">Attorney approval required</span></dd></div>
                  <div><dt>Authentication</dt><dd>Not connected in prototype</dd></div>
                </dl>
              </section>
              <section className="ops-panel ops-security-lockout" aria-labelledby="security-controls-title">
                <div>
                  <LockKeyhole aria-hidden="true" size={22} />
                  <div>
                    <h2 id="security-controls-title">Security controls are not active</h2>
                    <p>Password, multi-factor authentication, and session controls require a production identity provider.</p>
                  </div>
                </div>
                <button type="button" className="ops-secondary-button" disabled>Manage sign-in</button>
              </section>
            </>
          ) : null}
        </div>
      </div>
    </>
  );
}

function TogglePreference({ label, detail, checked, onChange }: { label: string; detail: string; checked: boolean; onChange: (checked: boolean) => void }) {
  return (
    <div className="ops-preference-row">
      <div><strong>{label}</strong><p>{detail}</p></div>
      <button type="button" className={`ops-switch ${checked ? "is-on" : ""}`} role="switch" aria-label={`${label}: ${checked ? "on" : "off"}`} aria-checked={checked} onClick={() => onChange(!checked)}>
        <span aria-hidden="true" />
        <b>{checked ? "On" : "Off"}</b>
      </button>
    </div>
  );
}
