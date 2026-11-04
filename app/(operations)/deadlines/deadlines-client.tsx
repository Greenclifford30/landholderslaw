"use client";

import Link from "next/link";
import { AlertTriangle, ArrowRight, CalendarClock, CheckCircle2, FileText, Scale, UserRound } from "lucide-react";
import { useMemo, useRef, useState } from "react";
import { DetailDrawer } from "../_components/detail-drawer";
import { deadlines, matters, PROTOTYPE_DATE } from "../_lib/data";
import type { Deadline, DeadlineState } from "../_lib/types";

type DeadlineFilter = "all" | "contractual" | "mine";

function deadlineTone(state: DeadlineState) {
  if (state === "Overdue") return "critical";
  if (state === "Due Today") return "warning";
  if (state === "Satisfied") return "success";
  return "normal";
}

export function DeadlinesClient() {
  const [filter, setFilter] = useState<DeadlineFilter>("all");
  const [selectedDeadline, setSelectedDeadline] = useState<Deadline | null>(null);
  const returnFocusRef = useRef<HTMLElement | null>(null);

  const filteredDeadlines = useMemo(() => deadlines
    .filter((deadline) => {
      if (filter === "contractual") return deadline.contractual;
      if (filter === "mine") return deadline.owner === "Jordan Lee";
      return true;
    })
    .sort((a, b) => a.date.localeCompare(b.date)), [filter]);

  function openDeadline(deadline: Deadline, trigger: HTMLElement) {
    returnFocusRef.current = trigger;
    setSelectedDeadline(deadline);
  }

  return (
    <>
      <header className="ops-page-heading">
        <div>
          <p className="ops-page-date">Tuesday, {PROTOTYPE_DATE}</p>
          <h1>Deadlines</h1>
          <p>Controlling dates across the active caseload, with contractual dates kept explicit.</p>
        </div>
        <Link href="/tasks" className="ops-secondary-button">View my tasks <ArrowRight aria-hidden="true" size={17} /></Link>
      </header>

      <section className="ops-date-horizon" aria-label="Seven day deadline horizon">
        <div className="is-past"><span>Mon</span><strong>02</strong><small>1 overdue</small></div>
        <div className="is-today"><span>Tue</span><strong>03</strong><small>1 due today</small></div>
        <div><span>Wed</span><strong>04</strong><small>No dates</small></div>
        <div className="has-date"><span>Thu</span><strong>05</strong><small>1 approval</small></div>
        <div className="has-date"><span>Fri</span><strong>06</strong><small>1 follow-up</small></div>
        <div><span>Sat</span><strong>07</strong><small>No dates</small></div>
        <div><span>Sun</span><strong>08</strong><small>No dates</small></div>
      </section>

      <div className="ops-deadline-layout">
        <section className="ops-panel" aria-labelledby="deadline-ledger-title">
          <header className="ops-panel-heading"><div><h2 id="deadline-ledger-title">Deadline ledger</h2><p>Chronological from overdue through upcoming.</p></div><span className="ops-count-label">{filteredDeadlines.length} dates</span></header>
          <div className="ops-tabs" role="tablist" aria-label="Filter deadlines">
            <button type="button" role="tab" aria-selected={filter === "all"} className={filter === "all" ? "is-selected" : ""} onClick={() => setFilter("all")}>All dates</button>
            <button type="button" role="tab" aria-selected={filter === "contractual"} className={filter === "contractual" ? "is-selected" : ""} onClick={() => setFilter("contractual")}>Contractual only</button>
            <button type="button" role="tab" aria-selected={filter === "mine"} className={filter === "mine" ? "is-selected" : ""} onClick={() => setFilter("mine")}>Assigned to me</button>
          </div>
          <div className="ops-deadline-ledger">
            {filteredDeadlines.map((deadline) => {
              const matter = matters.find((entry) => entry.id === deadline.matterId);
              const tone = deadlineTone(deadline.state);
              return (
                <article className={`ops-deadline-row is-${tone}`} key={deadline.id}>
                  <time dateTime={deadline.date}><strong>{deadline.dateLabel.split(" ")[1]}</strong><span>{deadline.dateLabel.split(" ")[0]}</span></time>
                  <div className="ops-deadline-connector" aria-hidden="true"><span /></div>
                  <div className="ops-deadline-copy">
                    <div><span className={`ops-status-text is-${tone}`}>{deadline.state}</span>{deadline.contractual ? <span className="ops-contract-label"><Scale aria-hidden="true" size={13} /> Contractual</span> : <span className="ops-contract-label"><FileText aria-hidden="true" size={13} /> Operational</span>}</div>
                    <h3>{deadline.title}</h3>
                    <p>{matter?.reference} · {matter?.client} · {matter?.property}</p>
                  </div>
                  <div className="ops-deadline-owner"><span>Owner</span><strong>{deadline.owner}</strong>{deadline.timeLabel ? <small>{deadline.timeLabel}</small> : null}</div>
                  <button type="button" className="ops-row-action" aria-label={`View ${deadline.title}`} onClick={(event) => openDeadline(deadline, event.currentTarget)}><ArrowRight aria-hidden="true" size={17} /></button>
                </article>
              );
            })}
          </div>
        </section>

        <aside className="ops-deadline-side">
          <section className="ops-panel"><header className="ops-panel-heading"><div><h2>Deadline health</h2><p>Current fictional caseload.</p></div><CalendarClock aria-hidden="true" size={20} /></header><dl className="ops-health-list"><div><dt><AlertTriangle aria-hidden="true" size={16} /> Overdue</dt><dd className="is-critical">1</dd></div><div><dt><CalendarClock aria-hidden="true" size={16} /> Due today</dt><dd className="is-warning">1</dd></div><div><dt><CheckCircle2 aria-hidden="true" size={16} /> Upcoming</dt><dd>4</dd></div></dl></section>
          <section className="ops-panel ops-reminder-note"><header className="ops-panel-heading"><div><h2>Reminder cadence</h2><p>Prototype behavior.</p></div></header><div><strong>8:30 AM daily</strong><p>Overdue contractual dates remain in the attention queue until a revised or satisfied date is recorded.</p></div></section>
        </aside>
      </div>

      <DetailDrawer title={selectedDeadline?.title ?? "Deadline details"} description={selectedDeadline ? `${selectedDeadline.state} · ${selectedDeadline.dateLabel}` : undefined} open={Boolean(selectedDeadline)} onClose={() => setSelectedDeadline(null)} returnFocusRef={returnFocusRef}>
        {selectedDeadline ? (
          <div className="ops-detail-stack">
            <div className={`ops-callout is-${deadlineTone(selectedDeadline.state)}`}><AlertTriangle aria-hidden="true" size={19} /><p>{selectedDeadline.state === "Overdue" ? "This controlling date is overdue and remains unresolved in the active matter." : "This date is active in the transaction timeline and visible to its assigned owner."}</p></div>
            <dl className="ops-detail-list"><div><dt>Matter</dt><dd>{matters.find((matter) => matter.id === selectedDeadline.matterId)?.reference}</dd></div><div><dt>Date</dt><dd>{selectedDeadline.dateLabel}{selectedDeadline.timeLabel ? ` at ${selectedDeadline.timeLabel}` : ""}</dd></div><div><dt>Owner</dt><dd>{selectedDeadline.owner}</dd></div><div><dt>Type</dt><dd>{selectedDeadline.contractual ? "Contractual" : "Operational"}</dd></div></dl>
            {selectedDeadline.lastReminder ? <div className="ops-permission-note"><UserRound aria-hidden="true" size={18} /><div><strong>Last reminder</strong><p>{selectedDeadline.lastReminder}</p></div></div> : null}
            <Link href={`/matters/${selectedDeadline.matterId}`} className="ops-primary-button">Open matter <ArrowRight aria-hidden="true" size={17} /></Link>
          </div>
        ) : null}
      </DetailDrawer>
    </>
  );
}
