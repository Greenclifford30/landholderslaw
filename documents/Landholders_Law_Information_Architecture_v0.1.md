# Landholders Law — Application Information Architecture

**Version:** 0.1  
**Date:** November 2, 2026  
**Status:** Proposed design baseline for external mockups  
**Product:** Landholders Law — Internal Transaction Management Platform  
**Source:** Landholders Law PRD v1.0 and Buyer/Seller workflow discovery

> **Purpose:** Provide a platform-independent information architecture and screen-level design brief for an external design/mockup tool. This document specifies navigation, content structure, role-sensitive interactions, user journeys, and core screen states. It is **not** a final visual design or a technical architecture specification.

## 1. Product context and design goals

Landholders Law currently manages Buyer and Seller residential real estate transactions primarily through manual processes, with some files and signature workflows handled in DocuSign. The MVP is for **internal staff only**, with two business roles: **Operations** and **Attorney**.

### Primary design principle

The application is **matter-centric**: each transaction has one central workspace that gathers workflow progress, tasks, deadlines, documents, legal correspondence, issues, closing readiness, and history. Global views provide queues across matters, but should link back to the same underlying records rather than duplicate them.

### Design objectives

1. A staff member can immediately identify **what needs attention next**, who owns it, and when it is due.
2. Buyer and Seller matters share a consistent UI shell while showing **different applicable workflow tasks and requirements**.
3. Complex decisions—Attorney approval, exception authorization, and closing readiness—are clear, traceable, and appropriately restricted.
4. Routine work requires few clicks; advanced detail remains available without overwhelming the primary view.
5. Waiting, blocked, incomplete, and excepted are visually distinct from completed.
6. The interface supports desktop-first use, with tablet-friendly layouts and accessible keyboard interactions.

## 2. Approved business constraints to respect in all mockups

| ID | Confirmed policy | UI implications |
|---|---|---|
| BP-01 | Internal users only for MVP | No client, realtor, lender, or title-company portal |
| BP-02 | Separate Buyer and Seller workflow templates | Shared layout, type-specific tasks and conditions |
| BP-03 | Both roles can create and edit deadlines | Show edit access to Operations and Attorney; log change reasons |
| BP-04 | DocuSign URLs and statuses tracked manually | Document link field, manual status selector; no assumed automatic sync |
| BP-05 | Only Attorney may approve closing-readiness overrides | Operations may request but not approve overrides |
| BP-06 | Deadline reminders via email and in-app dashboard | Notifications appear in global and matter views |
| BP-07 | Standard workflow generated automatically; staff may add custom tasks | Provide Add Task and distinguish standard vs. custom |
| BP-08 | Exceptions to required procedures need justification and Attorney authorization | Request/approve/reject flow with history |
| BP-09 | **All outgoing legal correspondence requires Attorney approval** | Draft → review → approved for sending → manually record sent |
| BP-10 | Either role may close or reopen a matter, with a recorded reason | Closure and reopening forms require reason and preserve history |
| BP-11 | Overdue deadline reminders recur **every business day until resolved** | Persistent overdue indicator, reminder history; do not imply one-time notification |

**Safety and legal caveat:** An internal Attorney exception cannot be assumed to waive an externally non-waivable legal or contractual duty. Mockups should visibly preserve outstanding requirements even when readiness has an approved exception.

## 3. Global application navigation

### 3.1 Primary destinations

| Destination | Purpose | Typical content | Audience |
|---|---|---|---|
| **Dashboard** | Daily operational command center | Attention items, active matters, my tasks, deadlines, approvals, blockers | Both |
| **Matters** | Transaction directory and creation | Search, filters, matter list, New Matter | Both |
| **My Tasks** | Work queue across matters | Assigned to Me / All Tasks, status and due-date filters | Both |
| **Deadlines** | Date-centric queue across matters | Overdue, today, upcoming, historical; list primarily, calendar optional | Both |
| **Approvals** | Review and tracking queue | Attorney decision queue; Operations submissions and outcomes | Both, role-sensitive |
| **Settings** | Account and firm configuration | Profile, notifications, users (authorized), reference settings | Authorized staff |

### 3.2 Global application shell

- Persistent app brand/title: **Landholders Law**.
- Primary navigation: Dashboard, Matters, My Tasks, Deadlines, Approvals, Settings.
- Global matter search by client name, property address, or matter reference.
- Current signed-in user and role.
- Notification indicator with unread/actionable states.
- Clear distinction between the global application and an individual Matter Workspace.
- Prefer left sidebar navigation on desktop; responsive compact navigation on tablet/mobile.

### 3.3 Proposed route map (implementation-oriented convention, not required URL design)

```text
/dashboard
/matters
/matters/new
/matters/:id                 (Overview)
/matters/:id/workflow
/matters/:id/tasks
/matters/:id/documents
/matters/:id/deadlines
/matters/:id/correspondence
/matters/:id/issues
/matters/:id/closing
/matters/:id/activity
/tasks
/deadlines
/approvals
/settings
```

Individual task/document/approval details can open in a side drawer or contextual panel instead of a separate full-screen page.

## 4. Global screens: mockup specifications

### 4.1 Dashboard

**Goal:** Answer, “What needs my attention today?” without reading every matter.

**Primary blocks:**

- Summary cards: Active Matters, My Pending Tasks, Upcoming Deadlines, Pending Approvals.
- **Requires Attention** queue, ordered by severity/urgency (overdue deadlines, pending legal approvals, blocked items, closing prerequisites).
- My Tasks (top few).
- Upcoming/Overdue Deadlines (due date, matter, owner, and status).
- Recent/active matters (optional compact block).
- Link from every actionable row to the relevant task/approval/deadline in its matter.

**Key states:** no matters yet; no urgent items; normal activity; overdue deadlines; unread notifications; Attorney approval backlog.

**Illustrative sample content only:** “Buyer #1042 — Financing contingency due tomorrow,” “Seller #1067 — Attorney review pending,” “Seller #1093 — Zoning certificate outstanding.” These are fictional and not actual firm records.

### 4.2 Matters directory

**Goal:** Locate any transaction quickly and open or create a matter.

**Layout:** search and filters at top; table/list with one row per matter; **New Matter** primary action.

**Suggested columns:** Matter reference, client/property, Buyer/Seller type, matter status, responsible team, next action, next deadline, anticipated closing date.

**Filters:** type, status, owner, closing date, optionally municipality; support sort by attention priority or closing date.

**States:** empty firm, empty filtered result, populated list, loading, archived/closed view.

### 4.3 New Matter intake

**Goal:** Create a Buyer or Seller matter with minimal friction.

**Proposed sections:**

1. Choose **Buyer** or **Seller**.
2. Client and contact details.
3. Property address, municipality, property type, condominium status, unit count.
4. Contract details: contract date, expected closing date, other initially known deadlines.
5. Assign Attorney and Operations.
6. Save as Draft or **Activate Matter** (initializes corresponding workflow).

**Important:** If needed intake information is missing, allow Save Draft; identify fields needed for activation. Conditional selections (e.g. condo / Chicago / unit count) should preview applicable tasks, without claiming legal compliance is fully verified.

**States:** blank, partially filled, validation errors, saved draft, successfully activated.

### 4.4 My Tasks

**Goal:** Work efficiently across multiple matters.

**Views:** Assigned to Me (default); All Tasks (with filters). Optional grouping by Due Date, Matter, or Status.

**Each row includes:** task title, matter reference/property, type (standard/custom/conditional), assigned user, due date, status, approval flag when applicable.

**Actions:** open task, mark ordinary task complete, change status, reassign where permitted, add custom task within a matter.

**Detailed tasks:** show description, dependencies, document links, comments, timestamps, activity history, and exception request if a required step cannot be fulfilled.

### 4.5 Deadlines

**Goal:** Surface time-sensitive work and keep effective dates accurate.

**Primary design:** chronological list with tabs/filters **Overdue**, **Today**, **Next 7 Days**, **Next 30 Days**, **All**; optional calendar view later.

**Deadline row:** matter, type, effective due date (and time if any), owner, status, days remaining/overdue, last reminder.

**Actions:** add deadline, edit with reason, mark satisfied, record extension/confirmed revised date, view change history.

**Never automatically change contractual deadlines simply because closing is rescheduled, a matter is on hold, or an extension is requested.** Show those as review conditions.

### 4.6 Approvals

**Goal:** Prevent unauthorized legal correspondence and exceptions while keeping review efficient.

**Attorney view:** Pending correspondence; exception requests; closing overrides; returned/decided history.

**Operations view:** Submitted requests; Awaiting Attorney; Changes Requested; Approved for Sending; decision history. No Attorney-only approval buttons.

**Each approval item:** matter, category, linked draft/requirement, version, requester, submitted date, decision status, action required.

**Actions (Attorney):** approve, request changes, reject, conditionally approve where applicable, view prior review rounds.

**Actions (Operations):** submit draft/request, revise and resubmit, record sending of approved legal correspondence.

## 5. Matter Workspace: shared shell

### 5.1 Purpose

A Matter Workspace is the central record of a particular Buyer or Seller transaction. It should be consistent across the two workflow types.

### 5.2 Persistent matter header

- Matter reference and property address prominently displayed.
- Client name; Buyer/Seller label.
- Current matter status (Draft, Active, On Hold, Closing Scheduled, Post-Closing Pending, File Closed, or Canceled).
- Assigned Attorney and Operations.
- Planned closing date and next critical deadline.
- Breadcrumb back to Matters directory.
- Contextual actions: Edit Matter, Add Task, Add Deadline, Close/Reopen (when appropriate).

### 5.3 Workspace tabs

| Tab | Key question | Contents and interactions |
|---|---|---|
| **Overview** | What is happening in this matter? | Status, phase progress, next actions, next deadlines, blockers, document/issue counts |
| **Workflow** | Which business steps apply, and what's complete? | Expandable Buyer/Seller phases and conditional task groups |
| **Tasks** | What must someone do? | Standard/custom tasks, status, dependencies, owners, exceptions |
| **Documents** | What documents exist or are missing? | Required checklist, uploads, external DocuSign links, manual signature statuses |
| **Deadlines** | What dates control this transaction? | Contractual/internal dates, edit history, extension records, reminders |
| **Correspondence** | What legal communications are pending review or sent? | Draft versions, Attorney approval, revision cycles, manual send logs |
| **Issues** | What is unresolved? | Inspection objections, title exceptions, financing and other issues; assignments/resolutions |
| **Closing** | Is this ready, and what happens afterward? | Readiness checklist, Attorney overrides, closing details, post-closing obligations, closure |
| **Activity** | What happened and who changed it? | Chronological audit of meaningful state changes and decisions |

**Design note:** Mockups can test whether some less-used tabs (such as Activity) should live under an overflow menu, but their functionality must remain discoverable.

## 6. Matter Workspace: detailed screen guidance

### 6.1 Overview (default landing tab)

**Visual priority:** Matter header → next required action → upcoming deadline → progress and blockers → deeper links.

**Sections:**

- High-level Buyer/Seller workflow progress by phase.
- Next Required Actions list with owner and state.
- Closest important deadlines and overdue indicators.
- Current pending Attorney approval(s).
- Summary counts for Documents, Open Issues, and Deadlines.
- Closing readiness summary when relevant.

**Design requirement:** Completed real estate closing must be visually distinct from **File Closed**; post-closing work may remain.

### 6.2 Workflow

Display the underlying process as an **expandable phase list / accordion**, not a giant flowchart as the main daily-use interface. Show phase status and number of completed / applicable tasks. Expand to view tasks, owners, due dates, conditions, and dependencies.

**Buyer phases:** File Opening; Initial Due Diligence; Inspection & Attorney Review; Financing; Closing; Post-Closing.

**Seller phases:** File Opening; Title & Earnest Money; Property Requirements; Attorney Review; Title Clearance; Closing (with post-closing follow-up as applicable).

Multiple phases may have active work in parallel. Do not impose one global linear step gate unless a specific dependency requires it.

**Task type markers:** Standard, Conditional, Custom. **Task states:** Not Started, In Progress, Waiting, Under Review, Blocked, Completed, Not Applicable.

### 6.3 Tasks

List all matter tasks, including staff-added custom tasks. Support filters by owner, status, phase, and type.

**Task detail drawer:** title, type, description, owner, status, due date, required/optional indicator, related documents/issues, prerequisites, notes, activity, Add Follow-up, Request Exception when applicable.

**Required-task rule:** cannot be silently deleted or marked fulfilled using an unauthorized exception.

### 6.4 Documents

**Top:** Missing Required Documents / Awaiting Signature / Recently Received.

**Document record:** title, category, requirement type (required/conditional/optional), status, owner, upload or external URL, last status update, related task.

**DocuSign:** store link and manual status, clearly labeled as **Manually Updated**; opening the link follows DocuSign's own permissions. Do not imply automatic sync, embedded signing, or API-confirmed signature.

### 6.5 Deadlines

Show chronological list tied to the selected matter. Each entry allows authorized edits by either role and shows prior dates / reason for adjustment.

Highlight **contractual** versus **internal target** dates. Overdue statuses remain in-app and generate email reminders each business day until resolved/superseded/canceled.

### 6.6 Correspondence

Mandatory process for **all outgoing legal correspondence**:

1. Register draft and its version.
2. Submit for Attorney review (or Attorney records approval of their own draft, if firm policy confirms self-approval).
3. Attorney approves, rejects, or returns with comments.
4. If revised materially, resubmit the updated version for approval.
5. Once approved, display **Approved for Sending**.
6. Staff send using existing external tools and manually log recipient, method, sender, and sent timestamp.

**States:** Draft, Pending Attorney Approval, Changes Requested, Approved for Sending, Sent, Rejected/Withdrawn.

A prior-version approval does not automatically approve a new version. The MVP cannot technically prevent someone from sending outside the app; mockups should show controls that enforce the internal workflow.

### 6.7 Issues

Track issues individually (inspection/repairs, title, financing, municipality documents, post-closing, other). Each issue has summary, owner, status, deadline if applicable, notes, attachments/links, and resolution record.

A blocked issue should be easy to locate without hiding unrelated active tasks.

### 6.8 Closing

**Sections:** scheduled closing details; required readiness checklist; missing items; Attorney exception requests; readiness status; actual closing outcome; post-closing follow-up; file closure.

**Readiness states:** Not Ready, Ready, Ready with Exceptions. An Attorney-approved exception records scope and justification but does not erase or falsely complete the missing requirement.

**Closing actions:** Schedule/Reschedule; Review Readiness; Request Override; Attorney Approve/Reject; Record Actual Closing; Record Post-Closing Follow-Up; Close File; Reopen File.

Either Operations or Attorney can close/reopen, **with required reason and timestamp**, subject to validation of unresolved work. Closing a file is different from recording that the property transaction closed.

### 6.9 Activity

Chronological audit log: what changed, when, by whom, and where relevant why. Include deadline edits, task reopening, legal approvals, exception decisions, document status edits, closing, cancellation, and reopening.

Offer filters by activity type and user when helpful. Audit history is read-only to ordinary application users.

## 7. Core user journeys for mockup flows

### Journey J-01: Create a new Buyer or Seller matter

`Matters → New Matter → Select Type → Client & Property → Contract Details → Assign Staff → Save Draft / Activate → Matter Overview`

**Expected end state:** A matter exists; activation creates applicable workflow tasks, with no duplicate tasks.

### Journey J-02: Prepare and approve outgoing legal correspondence

`Matter → Correspondence → Register Draft → Submit for Review → Attorney Decision → [Revise & Resubmit if needed] → Approved for Sending → Record Sent`

**Expected end state:** An approved version and external-send record are traceable.

### Journey J-03: Respond to deadline alert

`Dashboard / Email Reminder → Deadline → Matter Context → Complete Requirement OR Record Extension Request → Confirm Effective Revised Date → Updated Reminders`

**Expected end state:** Current deadline and historical changes are visible; old reminders are suppressed when superseded.

### Journey J-04: Request closing exception

`Matter → Closing → Missing Requirement → Request Override (reason) → Attorney Approval Queue → Approve / Reject / Return → Closing Readiness Updated`

**Expected end state:** Ready with Exceptions only if a valid applicable Attorney approval exists; original outstanding requirement remains visible.

### Journey J-05: Close and reopen matter

`Matter → Closing → Review Open Obligations → Close with Reason → Read-only/Closed Matter → Reopen with Reason → Resume Active Work`

**Expected end state:** Both roles can perform closure/reopening with traceable reasons; history persists.

### Journey J-06: Add and complete custom task

`Matter → Tasks → Add Task → Specify Owner & Details → Save → Update Status → Complete`

**Expected end state:** Custom task lives alongside standard tasks without changing the firm workflow template.

## 8. Interaction and visual design rules

1. **Always preserve matter context:** reference, property, type, and status visible on matter screens.
2. **Only one underlying record per item:** global queues and matter views display the same task/deadline/document, not copies.
3. **Quick actions for routine work:** status and assignment changes available from list or drawer when safe.
4. **Explicit confirmation for material actions:** Attorney overrides, changes to controlling dates, closure/reopening, and cancellations require context and/or recorded reason.
5. **Role-sensitive controls:** Operations can see approval status but cannot invoke Attorney-only approvals.
6. **Status must not be color-only:** use text, icons, and accessible contrast.
7. **Prioritize issues and dates:** urgent and blocked work stands out without excessive dashboard noise.
8. **Distinguish read-only completed history from editable active records.**
9. **Buyer/Seller consistency:** same shell and tabs; workflow content and readiness rules vary by type.
10. **Responsive and accessible:** desktop first; tablet supported; keyboard focus, semantic labels, error feedback, and usable smaller-screen layouts.

## 9. Required screen states to mock up

| Screen | States to represent |
|---|---|
| Dashboard | Normal operations, overdue urgent work, nothing urgent |
| Matters | Populated, no matches, new/empty firm |
| New Matter | Blank, conditional property inputs, validation error, saved draft |
| Matter Overview | Buyer active, Seller active, blocked, post-closing pending |
| Workflow | Some phases complete, multiple phases active, conditionally inapplicable task |
| Tasks | New custom task, waiting on external party, blocked, completed/reopened |
| Documents | Missing required item, DocuSign awaiting signature, manually marked signed |
| Deadlines | Approaching, overdue, extension pending, revised/effective date |
| Correspondence | Draft, pending Attorney, returned for changes, approved for sending, sent |
| Approvals | Attorney action queue, Operations submitted queue, approved exception |
| Closing | Not Ready, Ready, Ready with Exceptions, closed with post-closing follow-up |
| Activity | Timeline with changes and reasons |

## 10. Suggested mockup delivery order

**Round 1 — Core shell and transaction workflows:**

1. Global application shell + Dashboard.
2. Matters directory.
3. New Matter intake.
4. Matter Overview.
5. Matter Workflow + Tasks.

**Round 2 — Control and exception flows:**

6. Correspondence creation and Attorney approval.
7. Deadlines global and matter views.
8. Documents with manual DocuSign tracking.
9. Issues and Closing Readiness, including override approval.
10. Activity / closure / reopening views.

For each, mock up at least one **Buyer** and one **Seller** variant where the process content differs, plus at least one actionable error or exception state.

## 11. Design validation questions (not yet business-approved)

- Should low-frequency tabs (e.g. Activity) move under **More**, or remain visible?
- Should the task detail open in a side drawer, modal, or full page?
- What is the minimum required intake information to activate a matter versus save a draft?
- Should the default dashboard emphasize **My Work** over practice-wide work?
- Which user(s) receive default overdue reminders beyond the assigned owner?
- What is the firm's exact definition of outgoing **legal correspondence** for approval purposes?
- May the Attorney formally self-approve correspondence they authored?
- Which items are non-waivable in closing readiness and property-specific workflows?
- What is the exact closure policy for matters with unresolved work?
- What is the firm's holiday calendar and daily email reminder dispatch time?

These are open questions for validation, **not** a reason to assume a legal or operational rule in the mockup.

## 12. Out of scope for MVP mockups

- Client, realtor, lender, title-provider, or public portals.
- Automatic DocuSign API sync, embedded signing, or provider-verified signature status.
- Automated sending of outgoing legal correspondence.
- AI-based document generation or contract extraction.
- Billing, payment processing, or trust-account ledger.
- Drag-and-drop workflow template builder.
- Automatic municipality, title vendor, or calendar-provider integrations.
- Advanced analytics and reporting.

## 13. Handoff checklist for external design system

The mockup output should include:

- Navigation sitemap and global application shell.
- Low-fidelity (then higher-fidelity) wireframes for the screens in §9.
- Clear Buyer and Seller sample content with fictional clients/addresses only.
- User-role differences in Approvals and closing overrides.
- Task, deadline, document, and issue statuses.
- The five principal business journeys in §7, plus custom-task creation.
- Empty, error, waiting, blocked, and unauthorized states.
- Visible distinction between **transaction closing**, **post-closing follow-up**, and **File Closed**.
- Annotation of open business rules rather than silently inventing them.

---

**Version note:** This IA reflects business decisions approved through November 2, 2026. It is intended as an input to mockup design and should be revised following usability and Attorney/Operations validation before being treated as final UI requirements.
