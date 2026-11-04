"use client";

import Link from "next/link";
import {
  AlertTriangle,
  ArrowRight,
  CalendarDays,
  CheckCircle2,
  Clock3,
  FileWarning,
  LockKeyhole,
  ShieldAlert,
} from "lucide-react";
import { useMemo, useRef, useState } from "react";
import { DetailDrawer } from "../_components/detail-drawer";
import { assignedTasks, attentionItems, matters, PROTOTYPE_DATE } from "../_lib/data";
import type { AttentionItem } from "../_lib/types";

type AttentionFilter = "all" | "overdue" | "approvals";

const filterLabels: Record<AttentionFilter, string> = {
  all: "All attention",
  overdue: "Overdue",
  approvals: "Approvals",
};

function attentionIcon(kind: AttentionItem["kind"]) {
  if (kind === "deadline") return <Clock3 aria-hidden="true" size={18} />;
  if (kind === "approval") return <ShieldAlert aria-hidden="true" size={18} />;
  return <FileWarning aria-hidden="true" size={18} />;
}

export function DashboardClient() {
  const [filter, setFilter] = useState<AttentionFilter>("all");
  const [selectedItem, setSelectedItem] = useState<AttentionItem | null>(null);
  const returnFocusRef = useRef<HTMLElement | null>(null);

  const filteredItems = useMemo(() => {
    if (filter === "overdue") return attentionItems.filter((item) => item.kind === "deadline");
    if (filter === "approvals") return attentionItems.filter((item) => item.kind === "approval");
    return attentionItems;
  }, [filter]);

  const activeMatters = matters.filter(
    (matter) => matter.status !== "File Closed" && matter.status !== "Canceled",
  ).length;
  const overdueCount = attentionItems.filter((item) => item.kind === "deadline").length;
  const approvalCount = attentionItems.filter((item) => item.kind === "approval").length;

  function openItem(item: AttentionItem, trigger: HTMLElement) {
    returnFocusRef.current = trigger;
    setSelectedItem(item);
  }

  return (
    <>
      <header className="ops-page-heading ops-dashboard-heading">
        <div>
          <p className="ops-page-date">Tuesday, {PROTOTYPE_DATE}</p>
          <h1>What needs attention today</h1>
          <p>Prioritized work across active Buyer and Seller matters.</p>
        </div>
        <Link href="/matters" className="ops-secondary-button">
          View all matters <ArrowRight aria-hidden="true" size={17} />
        </Link>
      </header>

      <section className="ops-status-ledger" aria-label="Operations summary">
        <div>
          <span>Active matters</span>
          <strong>{activeMatters}</strong>
          <small>Across the fictional caseload</small>
        </div>
        <div>
          <span>My pending tasks</span>
          <strong>{assignedTasks.filter((task) => task.state !== "Completed").length}</strong>
          <small>Assigned to Jordan Lee</small>
        </div>
        <div className="has-critical">
          <span>Overdue deadlines</span>
          <strong>{overdueCount}</strong>
          <small>Recurring reminder active</small>
        </div>
        <div>
          <span>Pending approvals</span>
          <strong>{approvalCount}</strong>
          <small>Attorney action required</small>
        </div>
      </section>

      <div className="ops-dashboard-grid">
        <section className="ops-panel ops-attention-panel" aria-labelledby="attention-title">
          <header className="ops-panel-heading">
            <div>
              <h2 id="attention-title">Requires attention</h2>
              <p>Ordered by urgency, then controlling date.</p>
            </div>
            <span className="ops-count-label">{filteredItems.length} items</span>
          </header>

          <div className="ops-tabs" role="tablist" aria-label="Filter attention items">
            {(Object.keys(filterLabels) as AttentionFilter[]).map((key) => (
              <button
                type="button"
                role="tab"
                aria-selected={filter === key}
                className={filter === key ? "is-selected" : ""}
                onClick={() => setFilter(key)}
                key={key}
              >
                {filterLabels[key]}
              </button>
            ))}
          </div>

          <div className="ops-deadline-spine">
            {filteredItems.map((item) => {
              const matter = matters.find((entry) => entry.id === item.matterId);
              return (
                <article className={`ops-spine-row is-${item.priority.toLowerCase()}`} key={item.id}>
                  <div className="ops-spine-marker" aria-hidden="true">
                    <span>{attentionIcon(item.kind)}</span>
                  </div>
                  <div className="ops-spine-content">
                    <div className="ops-spine-meta">
                      <span className={`ops-status-text is-${item.priority.toLowerCase()}`}>
                        {item.priority === "Critical" ? "Overdue" : item.kind === "approval" ? "Approval" : "Blocked"}
                      </span>
                      <span>{item.dueLabel}</span>
                    </div>
                    <h3>{item.title}</h3>
                    <p>{matter?.reference} · {matter?.property}</p>
                    <div className="ops-spine-footer">
                      <span>Owner: {item.owner}</span>
                      <button
                        type="button"
                        className="ops-text-button"
                        onClick={(event) => openItem(item, event.currentTarget)}
                      >
                        {item.actionLabel} <ArrowRight aria-hidden="true" size={15} />
                      </button>
                    </div>
                  </div>
                </article>
              );
            })}
          </div>
        </section>

        <div className="ops-dashboard-side">
          <section className="ops-panel" aria-labelledby="tasks-title">
            <header className="ops-panel-heading">
              <div>
                <h2 id="tasks-title">My tasks</h2>
                <p>Assigned to Operations.</p>
              </div>
              <CheckCircle2 aria-hidden="true" size={20} />
            </header>
            <div className="ops-compact-list">
              {assignedTasks.slice(0, 4).map((task) => (
                <Link href={`/matters/${task.matterId}`} key={task.id}>
                  <span className={`ops-state-dot is-${task.state.toLowerCase().replaceAll(" ", "-")}`} aria-hidden="true" />
                  <span>
                    <strong>{task.title}</strong>
                    <small>{task.state} · {task.dueLabel}</small>
                  </span>
                  <ArrowRight aria-hidden="true" size={15} />
                </Link>
              ))}
            </div>
          </section>

          <section className="ops-panel ops-next-days" aria-labelledby="next-days-title">
            <header className="ops-panel-heading">
              <div>
                <h2 id="next-days-title">Next 7 days</h2>
                <p>Dates after today.</p>
              </div>
              <CalendarDays aria-hidden="true" size={20} />
            </header>
            <div className="ops-date-list">
              {matters
                .filter((matter) => matter.nextDeadline.state === "Upcoming")
                .slice(0, 3)
                .map((matter) => (
                  <Link href={`/matters/${matter.id}`} key={matter.id}>
                    <time dateTime={matter.nextDeadline.date}>
                      <strong>{matter.nextDeadline.dateLabel.split(" ")[1]}</strong>
                      <span>{matter.nextDeadline.dateLabel.split(" ")[0]}</span>
                    </time>
                    <span>
                      <strong>{matter.nextDeadline.title}</strong>
                      <small>{matter.reference} · {matter.municipality}</small>
                    </span>
                  </Link>
                ))}
            </div>
          </section>
        </div>
      </div>

      <DetailDrawer
        title={selectedItem?.title ?? "Attention item"}
        description={selectedItem?.dueLabel}
        open={Boolean(selectedItem)}
        onClose={() => setSelectedItem(null)}
        returnFocusRef={returnFocusRef}
      >
        {selectedItem ? (
          <div className="ops-detail-stack">
            <div className={`ops-callout is-${selectedItem.priority.toLowerCase()}`}>
              <AlertTriangle aria-hidden="true" size={19} />
              <p>{selectedItem.summary}</p>
            </div>
            <dl className="ops-detail-list">
              <div><dt>Matter</dt><dd>{matters.find((matter) => matter.id === selectedItem.matterId)?.reference}</dd></div>
              <div><dt>Owner</dt><dd>{selectedItem.owner}</dd></div>
              <div><dt>Priority</dt><dd>{selectedItem.priority}</dd></div>
              <div><dt>Current state</dt><dd>{selectedItem.kind === "approval" ? "Pending Attorney Approval" : selectedItem.kind === "deadline" ? "Overdue" : "Blocked"}</dd></div>
            </dl>
            {selectedItem.attorneyOnly ? (
              <div className="ops-permission-note">
                <LockKeyhole aria-hidden="true" size={18} />
                <div>
                  <strong>Attorney decision required</strong>
                  <p>Operations can review the submission and decision status, but cannot approve it.</p>
                </div>
              </div>
            ) : null}
            <Link href={`/matters/${selectedItem.matterId}`} className="ops-primary-button">
              Open matter <ArrowRight aria-hidden="true" size={17} />
            </Link>
          </div>
        ) : null}
      </DetailDrawer>
    </>
  );
}

