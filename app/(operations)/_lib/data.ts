import type {
  Approval,
  AttentionItem,
  Deadline,
  MatterDetail,
  MatterSummary,
  Task,
  WorkflowPhase,
} from "./types";

export const PROTOTYPE_DATE = "November 3, 2026";

export const deadlines: Deadline[] = [
  {
    id: "deadline-1042-financing",
    matterId: "1042",
    title: "Financing contingency",
    date: "2026-11-02",
    dateLabel: "Nov 2",
    state: "Overdue",
    owner: "Jordan Lee",
    contractual: true,
    lastReminder: "Today, 8:30 AM",
  },
  {
    id: "deadline-1067-review",
    matterId: "1067",
    title: "Attorney review response",
    date: "2026-11-03",
    dateLabel: "Nov 3",
    timeLabel: "4:00 PM",
    state: "Due Today",
    owner: "Ted M. Word",
    contractual: true,
    lastReminder: "Today, 8:30 AM",
  },
  {
    id: "deadline-1093-zoning",
    matterId: "1093",
    title: "Zoning certificate follow-up",
    date: "2026-11-06",
    dateLabel: "Nov 6",
    state: "Upcoming",
    owner: "Jordan Lee",
    contractual: false,
  },
  {
    id: "deadline-1101-title",
    matterId: "1101",
    title: "Title commitment review",
    date: "2026-11-09",
    dateLabel: "Nov 9",
    state: "Upcoming",
    owner: "Ted M. Word",
    contractual: false,
  },
  {
    id: "deadline-1114-closing",
    matterId: "1114",
    title: "Confirm closing package",
    date: "2026-11-12",
    dateLabel: "Nov 12",
    state: "Upcoming",
    owner: "Jordan Lee",
    contractual: false,
  },
  {
    id: "deadline-1101-title-approval",
    matterId: "1101",
    title: "Title exception response decision",
    date: "2026-11-05",
    dateLabel: "Nov 5",
    state: "Upcoming",
    owner: "Ted M. Word",
    contractual: false,
  },
];

export const matters: MatterSummary[] = [
  {
    id: "1042",
    reference: "Buyer #1042",
    client: "Avery Brooks",
    property: "5324 S. Calumet Avenue",
    municipality: "Chicago",
    type: "Buyer",
    status: "Active",
    assignedAttorney: "Ted M. Word",
    assignedOperations: "Jordan Lee",
    nextAction: "Confirm lender extension",
    nextDeadline: deadlines[0],
    closingDate: "2026-11-20",
    closingDateLabel: "Nov 20, 2026",
    priority: "Critical",
    blockerCount: 1,
  },
  {
    id: "1067",
    reference: "Seller #1067",
    client: "Morgan Ellis",
    property: "2731 W. Harrison Street",
    municipality: "Chicago",
    type: "Seller",
    status: "Active",
    assignedAttorney: "Ted M. Word",
    assignedOperations: "Jordan Lee",
    nextAction: "Record Attorney review outcome",
    nextDeadline: deadlines[1],
    closingDate: "2026-11-18",
    closingDateLabel: "Nov 18, 2026",
    priority: "High",
    blockerCount: 0,
  },
  {
    id: "1093",
    reference: "Seller #1093",
    client: "Riley Foster",
    property: "814 E. 88th Place",
    municipality: "Chicago",
    type: "Seller",
    status: "Active",
    assignedAttorney: "Ted M. Word",
    assignedOperations: "Jordan Lee",
    nextAction: "Follow up on zoning certificate",
    nextDeadline: deadlines[2],
    closingDate: "2026-11-30",
    closingDateLabel: "Nov 30, 2026",
    priority: "High",
    blockerCount: 1,
  },
  {
    id: "1101",
    reference: "Buyer #1101",
    client: "Cameron Price",
    property: "1847 Ridge Road",
    municipality: "Homewood",
    type: "Buyer",
    status: "Closing Scheduled",
    assignedAttorney: "Ted M. Word",
    assignedOperations: "Jordan Lee",
    nextAction: "Review title commitment",
    nextDeadline: deadlines[3],
    closingDate: "2026-11-16",
    closingDateLabel: "Nov 16, 2026",
    priority: "Normal",
    blockerCount: 0,
  },
  {
    id: "1114",
    reference: "Seller #1114",
    client: "Taylor Monroe",
    property: "16630 Oakwood Drive",
    municipality: "Lansing",
    type: "Seller",
    status: "Post-Closing Pending",
    assignedAttorney: "Ted M. Word",
    assignedOperations: "Jordan Lee",
    nextAction: "Confirm final water certificate",
    nextDeadline: deadlines[4],
    closingDate: "2026-10-30",
    closingDateLabel: "Closed Oct 30, 2026",
    priority: "Normal",
    blockerCount: 0,
  },
];

export const attentionItems: AttentionItem[] = [
  {
    id: "attention-financing",
    matterId: "1042",
    kind: "deadline",
    title: "Financing contingency is overdue",
    summary:
      "The lender has not confirmed the requested extension. The contractual date remains outstanding until a revised effective date is recorded.",
    dueLabel: "1 business day overdue",
    owner: "Jordan Lee",
    priority: "Critical",
    actionLabel: "Review deadline",
  },
  {
    id: "attention-review",
    matterId: "1067",
    kind: "approval",
    title: "Attorney review response needs a decision",
    summary:
      "Version 2 of the proposed response was submitted this morning and cannot be recorded as sent until Attorney approval.",
    dueLabel: "Due today at 4:00 PM",
    owner: "Ted M. Word",
    priority: "High",
    actionLabel: "View approval",
    attorneyOnly: true,
  },
  {
    id: "attention-lender",
    matterId: "1042",
    kind: "blocker",
    title: "Waiting for lender documentation",
    summary:
      "Updated loan commitment evidence is still outstanding. The financing phase remains active and closing readiness is blocked.",
    dueLabel: "Waiting since Oct 30",
    owner: "Jordan Lee",
    priority: "High",
    actionLabel: "View blocker",
  },
  {
    id: "attention-zoning",
    matterId: "1093",
    kind: "blocker",
    title: "Zoning certificate remains outstanding",
    summary:
      "The municipality request is logged, but the certificate has not been received. Other active work can continue.",
    dueLabel: "Follow up by Nov 6",
    owner: "Jordan Lee",
    priority: "High",
    actionLabel: "View requirement",
  },
];

export const assignedTasks: Task[] = [
  {
    id: "task-extension",
    matterId: "1042",
    title: "Confirm financing extension with lender",
    state: "Blocked",
    owner: "Jordan Lee",
    dueLabel: "Overdue",
    type: "Conditional",
  },
  {
    id: "task-review",
    matterId: "1067",
    title: "Record Attorney review outcome",
    state: "Under Review",
    owner: "Jordan Lee",
    dueLabel: "Today",
    type: "Standard",
  },
  {
    id: "task-zoning",
    matterId: "1093",
    title: "Follow up with municipality",
    state: "Waiting",
    owner: "Jordan Lee",
    dueLabel: "Nov 6",
    type: "Conditional",
  },
  {
    id: "task-water",
    matterId: "1114",
    title: "Confirm final water certificate",
    state: "In Progress",
    owner: "Jordan Lee",
    dueLabel: "Nov 12",
    type: "Standard",
  },
  {
    id: "task-title-package",
    matterId: "1101",
    title: "Review title commitment exceptions",
    state: "Not Started",
    owner: "Jordan Lee",
    dueLabel: "Nov 9",
    type: "Standard",
  },
  {
    id: "task-closing-figures",
    matterId: "1067",
    title: "Confirm seller closing figures",
    state: "Not Started",
    owner: "Jordan Lee",
    dueLabel: "Nov 10",
    type: "Standard",
  },
];

export const approvals: Approval[] = [
  {
    id: "approval-review-response",
    matterId: "1067",
    title: "Attorney review response · version 2",
    submittedBy: "Jordan Lee",
    submittedLabel: "Today, 8:12 AM",
    dueLabel: "Today at 4:00 PM",
    state: "Awaiting Decision",
    version: "Version 2",
    summary:
      "Proposed response addresses the inspection credit and preserves the seller's requested closing date. Operations needs a decision before recording the response as sent.",
  },
  {
    id: "approval-financing-extension",
    matterId: "1042",
    title: "Financing contingency extension",
    submittedBy: "Jordan Lee",
    submittedLabel: "Yesterday, 3:46 PM",
    dueLabel: "Overdue since Nov 2",
    state: "Changes Requested",
    version: "Version 3",
    summary:
      "Draft extension records the lender-requested date while preserving the existing closing date. The revised effective date still needs confirmation.",
    decisionNote: "Confirm the effective date with the lender before resubmitting.",
  },
  {
    id: "approval-title-exceptions",
    matterId: "1101",
    title: "Title exception response",
    submittedBy: "Jordan Lee",
    submittedLabel: "Nov 2, 11:20 AM",
    dueLabel: "Due Nov 5",
    state: "Awaiting Decision",
    version: "Version 1",
    summary:
      "Proposed response identifies two exceptions for clearance and records the remaining items as accepted for closing preparation.",
  },
  {
    id: "approval-water-certificate",
    matterId: "1114",
    title: "Post-closing water certificate note",
    submittedBy: "Jordan Lee",
    submittedLabel: "Oct 30, 2:18 PM",
    dueLabel: "Approved Oct 30",
    state: "Approved",
    version: "Version 1",
    summary:
      "File note records the certificate follow-up owner and the expected municipality response window.",
    decisionNote: "Approved for the post-closing record.",
  },
];

const buyerPhases: WorkflowPhase[] = [
  { name: "File Opening", complete: 5, applicable: 5, state: "Complete", note: "Completed Oct 8" },
  { name: "Initial Due Diligence", complete: 4, applicable: 4, state: "Complete", note: "Completed Oct 16" },
  { name: "Inspection & Attorney Review", complete: 7, applicable: 7, state: "Complete", note: "Response approved" },
  { name: "Financing", complete: 3, applicable: 6, state: "Active", note: "1 blocker · 1 overdue" },
  { name: "Closing", complete: 1, applicable: 8, state: "Active", note: "Preparation may continue" },
  { name: "Post-Closing", complete: 0, applicable: 3, state: "Upcoming", note: "Not started" },
];

const sellerPhases: WorkflowPhase[] = [
  { name: "File Opening", complete: 5, applicable: 5, state: "Complete", note: "File established" },
  { name: "Title & Earnest Money", complete: 4, applicable: 5, state: "Active", note: "Review in progress" },
  { name: "Property Requirements", complete: 3, applicable: 5, state: "Active", note: "Conditional items open" },
  { name: "Attorney Review", complete: 2, applicable: 4, state: "Active", note: "Decision pending" },
  { name: "Title Clearance", complete: 0, applicable: 5, state: "Upcoming", note: "Not started" },
  { name: "Closing", complete: 0, applicable: 7, state: "Upcoming", note: "Not started" },
];

function tasksForMatter(matter: MatterSummary): Task[] {
  const specific = assignedTasks.filter((task) => task.matterId === matter.id);
  return [
    ...specific,
    {
      id: `task-${matter.id}-review-file`,
      matterId: matter.id,
      title: matter.type === "Buyer" ? "Review title materials" : "Confirm title materials received",
      state: matter.priority === "Normal" ? "In Progress" : "Not Started",
      owner: "Jordan Lee",
      dueLabel: matter.nextDeadline.dateLabel,
      type: "Standard",
    },
  ];
}

function buildDetail(matter: MatterSummary): MatterDetail {
  const isPrimary = matter.id === "1042";
  const matterAttention = attentionItems.filter((item) => item.matterId === matter.id);
  const matterDeadlines = deadlines.filter((deadline) => deadline.matterId === matter.id);

  return {
    ...matter,
    clientEmail: `${matter.client.toLowerCase().replaceAll(" ", ".")}@example.test`,
    clientPhone: "(312) 555-0148",
    openedLabel: matter.type === "Buyer" ? "October 8, 2026" : "October 12, 2026",
    tasks: tasksForMatter(matter),
    deadlines: matterDeadlines,
    attention: matterAttention,
    phases: matter.type === "Buyer" ? buyerPhases : sellerPhases,
    documentCount: isPrimary ? 14 : 9,
    missingDocumentCount: isPrimary ? 2 : matter.blockerCount,
    issueCount: isPrimary ? 2 : matter.blockerCount,
    pendingApprovalCount: matterAttention.filter((item) => item.kind === "approval").length,
    readiness: matter.status === "Post-Closing Pending" ? "Ready" : "Not Ready",
    readinessNote: isPrimary
      ? "Financing evidence and the effective contingency date must be resolved. No override has been requested."
      : matter.status === "Post-Closing Pending"
        ? "The transaction closed; post-closing follow-up remains before the file can be closed."
        : "Readiness review has not started.",
  };
}

export const matterDetails = Object.fromEntries(
  matters.map((matter) => [matter.id, buildDetail(matter)]),
) as Record<string, MatterDetail>;

export const notifications = [
  { id: "n1", title: "Daily overdue reminder", detail: "Buyer #1042 · Financing contingency", time: "8:30 AM" },
  { id: "n2", title: "Approval submitted", detail: "Seller #1067 · Attorney review response", time: "8:12 AM" },
  { id: "n3", title: "Status changed to Waiting", detail: "Seller #1093 · Zoning certificate", time: "Yesterday" },
];

export function getMatter(id: string): MatterDetail | undefined {
  return matterDetails[id];
}

export function getMatterSummary(id: string): MatterSummary | undefined {
  return matters.find((matter) => matter.id === id);
}

