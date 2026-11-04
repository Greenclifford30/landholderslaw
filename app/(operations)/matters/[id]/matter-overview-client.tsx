"use client";

import Link from "next/link";
import {
  AlertTriangle,
  ArrowLeft,
  ArrowRight,
  CalendarClock,
  Check,
  CircleDashed,
  Clock3,
  FileText,
  LockKeyhole,
  TriangleAlert,
} from "lucide-react";
import { useRef, useState } from "react";
import { DetailDrawer } from "../../_components/detail-drawer";
import type { AttentionItem, Deadline, MatterDetail, Task } from "../../_lib/types";

type DrawerContent =
  | { kind: "attention"; item: AttentionItem }
  | { kind: "deadline"; item: Deadline }
  | { kind: "task"; item: Task };

const workspaceTabs = [
  "Overview",
  "Workflow",
  "Tasks",
  "Documents",
  "Deadlines",
  "Correspondence",
  "Issues",
  "Closing",
  "Activity",
];

function drawerTitle(content: DrawerContent | null) {
  if (!content) return "Matter detail";
  return content.item.title;
}

export function MatterOverviewClient({ matter }: { matter: MatterDetail }) {
  const [drawerContent, setDrawerContent] = useState<DrawerContent | null>(null);
  const returnFocusRef = useRef<HTMLElement | null>(null);

  function openDrawer(content: DrawerContent, trigger: HTMLElement) {
    returnFocusRef.current = trigger;
    setDrawerContent(content);
  }

  const completion = matter.phases.reduce((sum, phase) => sum + phase.complete, 0);
  const applicable = matter.phases.reduce((sum, phase) => sum + phase.applicable, 0);

  return (
    <>
      <Link href="/matters" className="ops-back-link">
        <ArrowLeft aria-hidden="true" size={16} /> Back to matters
      </Link>

      <header className="ops-matter-header">
        <div className="ops-matter-title">
          <div>
            <span className={`ops-status-badge is-${matter.status.toLowerCase().replaceAll(" ", "-")}`}>
              {matter.status}
            </span>
            {matter.blockerCount ? (
              <span className="ops-blocker-label"><TriangleAlert aria-hidden="true" size={14} /> {matter.blockerCount} blocker</span>
            ) : null}
          </div>
          <h1>{matter.property}</h1>
          <p>{matter.reference} · {matter.client} · {matter.type}</p>
        </div>
        <div className="ops-matter-critical-date">
          <span>Next critical deadline</span>
          <strong>{matter.nextDeadline.dateLabel}</strong>
          <p>{matter.nextDeadline.title}</p>
        </div>
      </header>

      <dl className="ops-matter-metadata">
        <div><dt>Attorney</dt><dd>{matter.assignedAttorney}</dd></div>
        <div><dt>Operations</dt><dd>{matter.assignedOperations}</dd></div>
        <div><dt>Planned closing</dt><dd>{matter.closingDateLabel}</dd></div>
        <div><dt>Opened</dt><dd>{matter.openedLabel}</dd></div>
      </dl>

      <nav className="ops-workspace-tabs" aria-label="Matter workspace">
        {workspaceTabs.map((tab) =>
          tab === "Overview" ? (
            <span key={tab} aria-current="page" className="is-active">{tab}</span>
          ) : (
            <span key={tab} aria-disabled="true" title="Not included in this prototype">{tab}</span>
          ),
        )}
      </nav>

      <div className="ops-overview-layout">
        <div className="ops-overview-main">
          <section className="ops-panel" aria-labelledby="next-actions-title">
            <header className="ops-panel-heading">
              <div>
                <h2 id="next-actions-title">Next required actions</h2>
                <p>Open work, ordered by urgency.</p>
              </div>
              <span className="ops-count-label">{matter.attention.length + matter.tasks.length} open</span>
            </header>
            <div className="ops-action-list">
              {matter.attention.map((item) => (
                <button
                  type="button"
                  className={`is-${item.priority.toLowerCase()}`}
                  key={item.id}
                  onClick={(event) => openDrawer({ kind: "attention", item }, event.currentTarget)}
                >
                  <span className="ops-action-symbol">
                    {item.kind === "deadline" ? <Clock3 aria-hidden="true" size={18} /> : <AlertTriangle aria-hidden="true" size={18} />}
                  </span>
                  <span>
                    <strong>{item.title}</strong>
                    <small>{item.dueLabel} · Owner: {item.owner}</small>
                  </span>
                  <ArrowRight aria-hidden="true" size={17} />
                </button>
              ))}
              {matter.tasks.map((task) => (
                <button
                  type="button"
                  key={task.id}
                  onClick={(event) => openDrawer({ kind: "task", item: task }, event.currentTarget)}
                >
                  <span className="ops-action-symbol"><CircleDashed aria-hidden="true" size={18} /></span>
                  <span>
                    <strong>{task.title}</strong>
                    <small>{task.state} · Due {task.dueLabel}</small>
                  </span>
                  <ArrowRight aria-hidden="true" size={17} />
                </button>
              ))}
            </div>
          </section>

          <section className="ops-panel" aria-labelledby="workflow-title">
            <header className="ops-panel-heading">
              <div>
                <h2 id="workflow-title">{matter.type} workflow</h2>
                <p>{completion} of {applicable} applicable tasks complete. Multiple phases may remain active.</p>
              </div>
            </header>
            <div className="ops-phase-list">
              {matter.phases.map((phase) => (
                <div key={phase.name} className={`is-${phase.state.toLowerCase()}`}>
                  <span className="ops-phase-icon" aria-hidden="true">
                    {phase.state === "Complete" ? <Check size={16} /> : <span />}
                  </span>
                  <span className="ops-phase-name">
                    <strong>{phase.name}</strong>
                    <small>{phase.note}</small>
                  </span>
                  <span className="ops-phase-count">{phase.complete} / {phase.applicable}</span>
                  <span className="ops-phase-state">{phase.state}</span>
                </div>
              ))}
            </div>
          </section>
        </div>

        <aside className="ops-overview-side" aria-label="Matter status summaries">
          <section className="ops-panel ops-matter-deadlines" aria-labelledby="matter-deadlines-title">
            <header className="ops-panel-heading">
              <div>
                <h2 id="matter-deadlines-title">Controlling dates</h2>
                <p>Current effective dates.</p>
              </div>
              <CalendarClock aria-hidden="true" size={20} />
            </header>
            <div className="ops-mini-spine">
              {matter.deadlines.map((deadline) => (
                <button
                  type="button"
                  key={deadline.id}
                  onClick={(event) => openDrawer({ kind: "deadline", item: deadline }, event.currentTarget)}
                >
                  <time dateTime={deadline.date}>{deadline.dateLabel}</time>
                  <span>
                    <strong>{deadline.title}</strong>
                    <small>{deadline.state} · {deadline.contractual ? "Contractual" : "Internal"}</small>
                  </span>
                </button>
              ))}
            </div>
          </section>

          <section className="ops-panel ops-readiness" aria-labelledby="readiness-title">
            <header className="ops-panel-heading">
              <div>
                <h2 id="readiness-title">Closing readiness</h2>
                <p>Requirements remain visible until resolved.</p>
              </div>
            </header>
            <div>
              <span className={`ops-readiness-state is-${matter.readiness.toLowerCase().replaceAll(" ", "-")}`}>
                {matter.readiness}
              </span>
              <p>{matter.readinessNote}</p>
              <div className="ops-permission-note">
                <LockKeyhole aria-hidden="true" size={17} />
                <span>Only an Attorney may approve a readiness override.</span>
              </div>
            </div>
          </section>

          <section className="ops-panel ops-record-counts" aria-labelledby="records-title">
            <header className="ops-panel-heading">
              <div><h2 id="records-title">Matter records</h2></div>
              <FileText aria-hidden="true" size={20} />
            </header>
            <dl>
              <div><dt>Documents</dt><dd>{matter.documentCount}</dd></div>
              <div><dt>Missing required</dt><dd>{matter.missingDocumentCount}</dd></div>
              <div><dt>Open issues</dt><dd>{matter.issueCount}</dd></div>
              <div><dt>Pending approvals</dt><dd>{matter.pendingApprovalCount}</dd></div>
            </dl>
          </section>
        </aside>
      </div>

      <DetailDrawer
        title={drawerTitle(drawerContent)}
        description={drawerContent?.kind === "deadline" ? drawerContent.item.state : drawerContent?.kind === "task" ? drawerContent.item.state : drawerContent?.item.dueLabel}
        open={Boolean(drawerContent)}
        onClose={() => setDrawerContent(null)}
        returnFocusRef={returnFocusRef}
      >
        {drawerContent ? (
          <div className="ops-detail-stack">
            {drawerContent.kind === "attention" ? (
              <>
                <div className={`ops-callout is-${drawerContent.item.priority.toLowerCase()}`}>
                  <AlertTriangle aria-hidden="true" size={19} />
                  <p>{drawerContent.item.summary}</p>
                </div>
                <dl className="ops-detail-list">
                  <div><dt>Owner</dt><dd>{drawerContent.item.owner}</dd></div>
                  <div><dt>Priority</dt><dd>{drawerContent.item.priority}</dd></div>
                  <div><dt>State</dt><dd>{drawerContent.item.kind === "deadline" ? "Overdue" : "Blocked"}</dd></div>
                </dl>
              </>
            ) : drawerContent.kind === "deadline" ? (
              <dl className="ops-detail-list">
                <div><dt>Effective date</dt><dd>{drawerContent.item.dateLabel}</dd></div>
                <div><dt>Type</dt><dd>{drawerContent.item.contractual ? "Contractual deadline" : "Internal target"}</dd></div>
                <div><dt>Owner</dt><dd>{drawerContent.item.owner}</dd></div>
                <div><dt>Last reminder</dt><dd>{drawerContent.item.lastReminder ?? "Not yet sent"}</dd></div>
              </dl>
            ) : (
              <dl className="ops-detail-list">
                <div><dt>Status</dt><dd>{drawerContent.item.state}</dd></div>
                <div><dt>Owner</dt><dd>{drawerContent.item.owner}</dd></div>
                <div><dt>Due</dt><dd>{drawerContent.item.dueLabel}</dd></div>
                <div><dt>Task type</dt><dd>{drawerContent.item.type}</dd></div>
              </dl>
            )}
            <p className="ops-prototype-note">This prototype does not persist status, deadline, or assignment changes.</p>
          </div>
        ) : null}
      </DetailDrawer>
    </>
  );
}

