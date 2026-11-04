export type UserRole = "Operations" | "Attorney";

export type MatterType = "Buyer" | "Seller";

export type MatterStatus =
  | "Draft"
  | "Active"
  | "On Hold"
  | "Closing Scheduled"
  | "Post-Closing Pending"
  | "File Closed"
  | "Canceled";

export type Priority = "Critical" | "High" | "Normal";

export type DeadlineState = "Overdue" | "Due Today" | "Upcoming" | "Satisfied";

export type AttentionKind = "deadline" | "approval" | "blocker";

export type TaskState =
  | "Not Started"
  | "In Progress"
  | "Waiting"
  | "Under Review"
  | "Blocked"
  | "Completed";

export interface Deadline {
  id: string;
  matterId: string;
  title: string;
  date: string;
  dateLabel: string;
  timeLabel?: string;
  state: DeadlineState;
  owner: string;
  contractual: boolean;
  lastReminder?: string;
}

export interface Task {
  id: string;
  matterId: string;
  title: string;
  state: TaskState;
  owner: string;
  dueLabel: string;
  type: "Standard" | "Conditional" | "Custom";
}

export type ApprovalState = "Awaiting Decision" | "Changes Requested" | "Approved";

export interface Approval {
  id: string;
  matterId: string;
  title: string;
  submittedBy: string;
  submittedLabel: string;
  dueLabel: string;
  state: ApprovalState;
  version: string;
  summary: string;
  decisionNote?: string;
}

export interface AttentionItem {
  id: string;
  matterId: string;
  kind: AttentionKind;
  title: string;
  summary: string;
  dueLabel: string;
  owner: string;
  priority: Priority;
  actionLabel: string;
  attorneyOnly?: boolean;
}

export interface MatterSummary {
  id: string;
  reference: string;
  client: string;
  property: string;
  municipality: string;
  type: MatterType;
  status: MatterStatus;
  assignedAttorney: string;
  assignedOperations: string;
  nextAction: string;
  nextDeadline: Deadline;
  closingDate: string;
  closingDateLabel: string;
  priority: Priority;
  blockerCount: number;
}

export interface WorkflowPhase {
  name: string;
  complete: number;
  applicable: number;
  state: "Complete" | "Active" | "Upcoming";
  note: string;
}

export interface MatterDetail extends MatterSummary {
  clientEmail: string;
  clientPhone: string;
  openedLabel: string;
  tasks: Task[];
  deadlines: Deadline[];
  attention: AttentionItem[];
  phases: WorkflowPhase[];
  documentCount: number;
  missingDocumentCount: number;
  issueCount: number;
  pendingApprovalCount: number;
  readiness: "Not Ready" | "Ready" | "Ready with Exceptions";
  readinessNote: string;
}

