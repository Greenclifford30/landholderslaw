"use client";

import Link from "next/link";
import { ArrowRight, CheckCircle2, Clock3, FileText, LockKeyhole, MessageSquareText, ShieldCheck } from "lucide-react";
import { useMemo, useState } from "react";
import { approvals, matters, PROTOTYPE_DATE } from "../_lib/data";
import type { ApprovalState } from "../_lib/types";

type ApprovalFilter = "pending" | "changes" | "resolved" | "all";

const approvalFilters: Record<ApprovalFilter, string> = {
  pending: "Awaiting decision",
  changes: "Changes requested",
  resolved: "Resolved",
  all: "All",
};

function approvalTone(state: ApprovalState) {
  if (state === "Changes Requested") return "critical";
  if (state === "Approved") return "success";
  return "warning";
}

export function ApprovalsClient() {
  const [filter, setFilter] = useState<ApprovalFilter>("pending");
  const [selectedId, setSelectedId] = useState(approvals[0].id);

  const filteredApprovals = useMemo(() => approvals.filter((approval) => {
    if (filter === "pending") return approval.state === "Awaiting Decision";
    if (filter === "changes") return approval.state === "Changes Requested";
    if (filter === "resolved") return approval.state === "Approved";
    return true;
  }), [filter]);

  const selectedApproval = approvals.find((approval) => approval.id === selectedId) ?? filteredApprovals[0] ?? approvals[0];
  const selectedMatter = matters.find((matter) => matter.id === selectedApproval.matterId);

  function selectFilter(nextFilter: ApprovalFilter) {
    setFilter(nextFilter);
    const nextApproval = approvals.find((approval) => {
      if (nextFilter === "pending") return approval.state === "Awaiting Decision";
      if (nextFilter === "changes") return approval.state === "Changes Requested";
      if (nextFilter === "resolved") return approval.state === "Approved";
      return true;
    });
    if (nextApproval) setSelectedId(nextApproval.id);
  }

  return (
    <>
      <header className="ops-page-heading">
        <div>
          <p className="ops-page-date">Tuesday, {PROTOTYPE_DATE}</p>
          <h1>Approvals</h1>
          <p>Attorney decisions with the context Operations needs to keep each transaction moving.</p>
        </div>
        <div className="ops-role-boundary"><LockKeyhole aria-hidden="true" size={17} /><span>Signed in as Operations</span></div>
      </header>

      <section className="ops-status-ledger" aria-label="Approval summary">
        <div><span>Awaiting decision</span><strong>{approvals.filter((item) => item.state === "Awaiting Decision").length}</strong><small>Attorney action required</small></div>
        <div className="has-critical"><span>Changes requested</span><strong>{approvals.filter((item) => item.state === "Changes Requested").length}</strong><small>Return to Operations</small></div>
        <div><span>Due today</span><strong>1</strong><small>Attorney review response</small></div>
        <div><span>Resolved</span><strong>{approvals.filter((item) => item.state === "Approved").length}</strong><small>Visible in this mock</small></div>
      </section>

      <div className="ops-approval-layout">
        <section className="ops-panel" aria-labelledby="approval-queue-title">
          <header className="ops-panel-heading"><div><h2 id="approval-queue-title">Decision queue</h2><p>Oldest controlling date first.</p></div><ShieldCheck aria-hidden="true" size={20} /></header>
          <div className="ops-tabs" role="tablist" aria-label="Filter approvals">
            {(Object.keys(approvalFilters) as ApprovalFilter[]).map((key) => (
              <button type="button" role="tab" aria-selected={filter === key} className={filter === key ? "is-selected" : ""} onClick={() => selectFilter(key)} key={key}>{approvalFilters[key]}</button>
            ))}
          </div>
          <div className="ops-approval-queue">
            {filteredApprovals.map((approval) => {
              const matter = matters.find((entry) => entry.id === approval.matterId);
              const tone = approvalTone(approval.state);
              return (
                <button type="button" className={approval.id === selectedApproval.id ? "is-selected" : ""} aria-pressed={approval.id === selectedApproval.id} onClick={() => setSelectedId(approval.id)} key={approval.id}>
                  <span className={`ops-approval-symbol is-${tone}`} aria-hidden="true">{approval.state === "Approved" ? <CheckCircle2 size={18} /> : approval.state === "Changes Requested" ? <MessageSquareText size={18} /> : <Clock3 size={18} />}</span>
                  <span><strong>{approval.title}</strong><small>{matter?.reference} · {matter?.client}</small><small>{approval.submittedLabel} · {approval.version}</small></span>
                  <span className={`ops-queue-state is-${tone}`}>{approval.state}<small>{approval.dueLabel}</small></span>
                </button>
              );
            })}
          </div>
        </section>

        <section className="ops-panel ops-decision-sheet" aria-labelledby="decision-title">
          <header className="ops-panel-heading"><div><h2 id="decision-title">Decision record</h2><p>{selectedApproval.version} · submitted by {selectedApproval.submittedBy}</p></div><FileText aria-hidden="true" size={20} /></header>
          <div className="ops-decision-body">
            <div className="ops-decision-status">
              <span className={`ops-status-text is-${approvalTone(selectedApproval.state)}`}>{selectedApproval.state}</span>
              <strong>{selectedApproval.dueLabel}</strong>
            </div>
            <div className="ops-decision-title"><span>{selectedMatter?.reference}</span><h3>{selectedApproval.title}</h3><p>{selectedMatter?.property} · {selectedMatter?.municipality}, Illinois</p></div>
            <div className="ops-decision-summary"><span>Submission summary</span><p>{selectedApproval.summary}</p></div>
            {selectedApproval.decisionNote ? <div className="ops-decision-note"><MessageSquareText aria-hidden="true" size={18} /><div><strong>Decision note</strong><p>{selectedApproval.decisionNote}</p></div></div> : null}
            <dl className="ops-detail-list">
              <div><dt>Submitted</dt><dd>{selectedApproval.submittedLabel}</dd></div>
              <div><dt>Submitted by</dt><dd>{selectedApproval.submittedBy}</dd></div>
              <div><dt>Decision owner</dt><dd>Ted M. Word</dd></div>
            </dl>
            <div className="ops-attorney-actions">
              <button type="button" className="ops-primary-button" disabled><CheckCircle2 aria-hidden="true" size={17} /> Approve</button>
              <button type="button" className="ops-secondary-button" disabled>Request changes</button>
              <p><LockKeyhole aria-hidden="true" size={15} /> Attorney permissions are required for decision actions.</p>
            </div>
            <Link href={`/matters/${selectedApproval.matterId}`} className="ops-text-button">Open matter record <ArrowRight aria-hidden="true" size={16} /></Link>
          </div>
        </section>
      </div>
    </>
  );
}
