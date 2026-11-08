# Landholders Law — Product Requirements Document (PRD)

**Version:** 1.0 — Business Requirements Baseline  
**Date:** 2026-11-02  
**Product:** Landholders Law Transaction Management Platform  
**Release:** Internal Operations MVP  
**Status:** Business policies confirmed; detailed workflows and legal rule assumptions pending practitioner validation

## 1. Executive summary

Landholders Law currently operates buyer and seller real-estate transactions with manual process tracking and some documents stored or managed in DocuSign. The MVP will centralize internal matter records, standard and custom workflow tasks, deadlines, documents and DocuSign links, legal correspondence approvals, issues, closing-readiness checks, and audit history.

**Primary outcome:** An authorized team member can open any matter and see its current status, what is outstanding, who owns each action, which deadlines are approaching or overdue, and whether it is ready for closing.

### Scope

- **Included:** Internal Attorney and Operations users; Buyer and Seller residential transaction workflows; tasks, conditional actions, manual document status and links, email and in-app reminders, legal approvals, closing exceptions, file closure and reopening.
- **Excluded:** Client/realtor/lender/title-company portals, automated DocuSign API sync, automated external correspondence sending, payment processing, legal accounting, advanced AI authoring, comprehensive visual workflow builder.

## 2. Source process materials

- `Buyer Transaction Workflow.png` — six workflow phases: File Opening, Initial Due Diligence, Inspection/Attorney Review, Financing, Closing, Post-Closing.
- `Seller Process Map.png` — six workflow phases: File Opening, Title/Earnest Money, Property Requirements, Attorney Review, Title Clearance, Closing.
- `Legend.png` — swimlanes and workflow symbols.

**Interpretation note:** The phase and operation inventories below are based on the team's prior diagram decomposition; labels, sequencing, jurisdictional/legal conditions, and the applicability of individual requirements must be checked against the original diagrams and confirmed by Attorney and Operations before they become controlling legal automation.

## 3. Roles

| Role | Responsibilities | Permissions |
|---|---|---|
| Operations | Intake, coordination, tasks, documents, deadlines, communication preparation, closing logistics | Manage matters and deadlines, add tasks, request legal approval and exceptions; cannot approve legal correspondence or required-process exceptions |
| Attorney | Legal review, authorizing correspondence, legal issue decisions, permitted exceptions | All regular matter-management actions plus legal approvals and permitted exceptions |
| System | Workflow generation, conditional rules, reminders, status aggregation, audit events | Non-human automation subject to business rules |

Authentication is internal-only. Matter assignments do not restrict authorized users from viewing work, subject to the firm's eventual confidentiality model.

## 4. Confirmed business policies

| ID | Policy |
|---|---|
| BP-01 | Internal staff only for MVP |
| BP-02 | Separate standard Buyer and Seller workflow templates |
| BP-03 | Either Attorney or Operations may create and update contractual deadlines |
| BP-04 | Store DocuSign links; update statuses manually; no DocuSign integration required for MVP |
| BP-05 | Attorney may authorize permitted closing-readiness exceptions; retain explicit 'Ready with Exceptions' |
| BP-06 | Deadline reminders via email and in-app dashboard |
| BP-07 | Flexible workflows: auto-generated standard tasks and staff-created custom tasks |
| BP-08 | Justified deviations from mandatory procedures require appropriate Attorney authorization |
| BP-09 | **All outgoing legal correspondence requires Attorney approval** |
| BP-10 | **Either role may close and reopen a matter, with a recorded reason** |
| BP-11 | **Overdue deadline reminders repeat every business day until resolved** |

## 5. Workflow model and rules

### 5.1 Task categories

- **Standard:** Created from versioned Buyer/Seller templates; may not be silently deleted or treated as completed when excepted.
- **Conditional:** Generated from transaction facts such as condominium status, municipality, unit count, financing outcome, and other applicable conditions.
- **Custom:** Added by internal users for transaction-specific work; preserved independently of template definitions.

Task states: `Not Started`, `In Progress`, `Waiting`, `Under Review`, `Blocked`, `Completed`, `Not Applicable` (with a reason; mandatory work requires appropriate authorization).

Task records should include matter, category, title, description, assignee, due date if applicable, dependencies, status, created/updated timestamps, completion attribution, and activity history.

### 5.2 Workflow invariants

1. Template initialization is idempotent: activating a matter must not duplicate tasks.
2. Template versions are preserved for existing matters unless a controlled migration is approved.
3. Changes to property facts reevaluate conditional tasks, without deleting historical task or decision records.
4. Requirements can coexist across phases: the application should not impose an artificial entire-phase barrier where independent work can proceed in parallel.
5. Exceptions preserve the original requirement and its incomplete status; they do not falsify completion.
6. Required legal approvals and exceptions must be authorized server-side, not only hidden in the UI.

### 5.3 Matter lifecycle

Proposed statuses: `Draft`, `Active`, `On Hold`, `Closing Scheduled`, `Post-Closing Pending`, `File Closed`, `Canceled`. Closing readiness is a distinct attribute: `Not Ready`, `Ready`, `Ready with Exceptions`.

An on-hold state, a postponed closing, or a pending extension request does not automatically suspend or change contractual obligations. A real estate closing may be complete while the matter remains open for post-closing work.

## 6. Buyer workflow inventory

| ID | Business operation | Functional expectation |
|---|---|---|
| B-01 | Contract received | Start Buyer intake |
| B-02 | Create digital file | Establish unique matter |
| B-03 | Enter contract and deadline details | Capture contract dates and facts |
| B-04 | Create workflow/deadline tracking | Initialize tasks and monitoring |
| B-05 | Condo decision | Evaluate condominium branch |
| B-06 | Request/await condo documents | Track requested/received status |
| B-07 | Pull tax records | Attach or reference record |
| B-08 | Review taxes/exemptions | Complete review task |
| B-09 | Chicago property decision | Evaluate jurisdiction |
| B-10 | Check open building code violations | Activate if applicable |
| B-11 | Prepare retainer | Track draft agreement |
| B-12 | Send retainer via DocuSign | Store link; manually record send |
| B-13 | Await signed retainer | Track outstanding signature |
| B-14 | Confirm retainer/payment | Record manual confirmation |
| B-15 | Await inspection/repair requests | Track external dependency |
| B-16 | Receive inspection/repair requests | Attach receipt and details |
| B-17 | Draft attorney review correspondence | Create legal correspondence item |
| B-18 | Attorney reviews/revises/approves | Mandatory Attorney approval |
| B-19 | Send attorney review correspondence | Record external send only after approval |
| B-20 | Review complete decision | Record legal determination |
| B-21 | Outstanding issue tracking | Loop through unresolved objections |
| B-22 | Monitor financing contingency | Create effective contractual deadline |
| B-23 | Deadline reminder | Email and in-app notice |
| B-24 | Check financing status | Record latest status |
| B-25 | Clear-to-close decision | Record outcome |
| B-26 | Prepare extension request | Draft legal communication if necessary |
| B-27 | Attorney reviews/approves extension | Mandatory approval prior to recording send |
| B-28 | Send extension request | Track send; request alone does not alter deadline |
| B-29 | Enter confirmed new contingency date | Update effective date, retain previous value |
| B-30 | Restart monitoring | Recalculate future notifications |
| B-31 | Schedule closing | Record appointment |
| B-32 | Enter closing details | Capture location/date/time |
| B-33 | Update closing-scheduled status | Reflect milestone |
| B-34 | Real estate closing | Record event/outcome |
| B-35 | Receive title/settlement documents | Track final documents |
| B-36 | Save to digital file | Upload/link documents |
| B-37 | Post-closing issue/escrow decision | Assess remaining obligations |
| B-38 | Create follow-up | Assign remaining work |
| B-39 | Resolve post-closing file | Record resolution |
| B-40 | File closed | Finalize with reason and audit history |

**Buyer branches:** condominium documents; Chicago building-code check; iterative inspection/attorney review; financing deadline/extension loop; post-closing escrow/issue follow-up.

## 7. Seller workflow inventory

| ID | Business operation | Functional expectation |
|---|---|---|
| S-01 | Contract received | Start Seller intake |
| S-02 | Create digital file | Establish unique matter |
| S-03 | Enter contract/property information | Capture applicable facts |
| S-04 | Initialize Seller workflow/deadlines | Create tasks and monitoring |
| S-05 | Order title commitment (Fidelity in map) | Track order; provider configurable |
| S-06 | Title ordered/received | Track state |
| S-07 | Record title order number | Save reference |
| S-08 | Provide order information to buyer's side | Record communication; apply legal approval when applicable |
| S-09 | Await earnest money | Track outstanding requirement |
| S-10 | Confirm earnest money received | Record confirmation |
| S-11 | Pull tax records | Store reference |
| S-12 | Review taxes/exemptions | Complete review |
| S-13 | Municipality decision | Select jurisdiction requirements |
| S-14 | Unit count decision | Evaluate Chicago property branch |
| S-15 | One-unit zoning at closing | Track map-indicated requirement; validate legally |
| S-16 | 2+ unit zoning deadline, two weeks prior | Track map-indicated timing; validate legally |
| S-17 | Order zoning certificate | Record order |
| S-18 | Await zoning certificate | Track outstanding document |
| S-19 | Order water certificate | Track request/receipt |
| S-20 | Order survey | Track request/receipt |
| S-21 | Track property documents | Maintain outstanding list |
| S-22 | Await buyer attorney/repair requests | Track dependency |
| S-23 | Attorney review received | Record receipt |
| S-24 | Prepare response | Create draft |
| S-25 | Attorney reviews/revises/approves | Mandatory legal approval |
| S-26 | Send response | Record approved communication |
| S-27 | Review complete decision | Record determination |
| S-28 | Track outstanding issues | Iterate until resolved |
| S-29 | Review title issues | Create title findings |
| S-30 | Lien/ownership issue decision | Branch to resolution |
| S-31 | Resolve legal/title issue | Assign legal work |
| S-32 | Track resolution | Maintain open/closed state |
| S-33 | Verify required items | Evaluate prerequisites |
| S-34 | Track pre-closing requirements | Checklist of applicable items |
| S-35 | Everything complete decision | Determine readiness |
| S-36 | Flag missing items | Show not-ready causes |
| S-37 | Resolve/follow-up | Assign outstanding work |
| S-38 | Schedule closing | Record closing appointment |
| S-39 | Prepare/review closing documents | Assign preparation and approvals |
| S-40 | Update closing-scheduled status | Record milestone |
| S-41 | Real estate closing | Record event/outcome |
| S-42 | Confirm payment | Record manual confirmation |
| S-43 | Save final documents | Upload/link records |
| S-44 | Post-closing issue/escrow decision | Evaluate remaining obligations |
| S-45 | Create follow-up | Assign tasks |
| S-46 | Resolve follow-up | Record resolution |
| S-47 | Close matter | Require recorded reason |
| S-48 | File closed | Final status and history |

**Seller branches:** title/earnest-money tracking; municipality and unit-count-specific zoning/water/survey; iterative legal review; lien/ownership/title clearance; pre-closing completeness; post-closing follow-up.

## 8. Functional requirements with testable acceptance criteria

### MAT — Matters

| ID | Requirement | Acceptance criteria |
|---|---|---|
| MAT-001 | Create Buyer/Seller matter | Correct workflow type initialized and unique ID assigned |
| MAT-002 | Capture client/property/contract fields | Required data enforced for activation; drafts supported as proposed |
| MAT-003 | Assign Attorney and Operations | Both responsibilities displayed |
| MAT-004 | Edit matter information | Significant edits audited |
| MAT-005 | Search/filter matters | By ID, client, property, owner, type, status |
| MAT-006 | Track lifecycle status | Valid states and transitions recorded |

### WFL — Workflow/tasks

| ID | Requirement | Acceptance criteria |
|---|---|---|
| WFL-001 | Generate standard workflow | Exactly one set of tasks created on activation |
| WFL-002 | Add custom tasks | Either role creates and assigns a task |
| WFL-003 | Track task states | All defined states available with valid transition rules |
| WFL-004 | Conditional activation | Correct tasks respond to property/transaction facts |
| WFL-005 | Dependencies | Required prerequisites enforced without blocking independent work |
| WFL-006 | History | Status/reopen/reassignment events recorded |
| WFL-007 | Task exceptions | Mandatory tasks require documented Attorney authorization to bypass |
| WFL-008 | Versioned templates | Existing matters not silently modified by future templates |

### DDL — Deadlines

| ID | Requirement | Acceptance criteria |
|---|---|---|
| DDL-001 | Create deadlines | Either role creates contractual/internal deadline |
| DDL-002 | Edit effective dates | Old/new values and actor retained |
| DDL-003 | Assign deadline owner | Owner visible in matter and dashboard |
| DDL-004 | Advance reminders | Configured events shown in-app and emailed |
| DDL-005 | Recurring overdue reminders | Sent every business day while unresolved |
| DDL-006 | Stop reminders after resolution | No stale reminder jobs after satisfied/canceled/superseded |
| DDL-007 | Pending extension logic | Original effective date remains until confirmed update |
| DDL-008 | Deadline change audit | Date, user, reason recorded |

### DOC — Documents and DocuSign

| ID | Requirement | Acceptance criteria |
|---|---|---|
| DOC-001 | Document requirements | Required/conditional/optional classifications supported |
| DOC-002 | Document links | Store DocuSign URL and document type on matter |
| DOC-003 | Manual status | Record who asserted receipt/signature status and when |
| DOC-004 | File uploads | File linked to correct matter and access protected |
| DOC-005 | Missing document visibility | Outstanding items appear in matter and readiness review |

### APR — Legal correspondence/approvals

| ID | Requirement | Acceptance criteria |
|---|---|---|
| APR-001 | Register outgoing legal correspondence | Identifiable draft/version linked to matter |
| APR-002 | Mandatory Attorney approval | Cannot be internally marked approved for sending without Attorney action |
| APR-003 | Revision loop | Attorney returns with comments; revision resubmitted |
| APR-004 | History | Previous approval rounds preserved |
| APR-005 | Version-specific approval | Materially revised draft requires renewed approval |
| APR-006 | Record sending | Sender, date, recipient, method and reference saved |
| APR-007 | Role enforcement | Operations unable to grant Attorney approval |

**Limitation:** MVP does not send external email directly; it cannot technically prevent off-platform sending. Firm procedure must require staff to register and obtain approval for all outgoing legal correspondence.

### EXC — Issues and exceptions

| ID | Requirement | Acceptance criteria |
|---|---|---|
| EXC-001 | Track issues | Type, owner, status, notes supported |
| EXC-002 | Multiple concurrent issues | Each independently actionable |
| EXC-003 | Request exception | Justification and affected items required |
| EXC-004 | Attorney authorization | Operations cannot approve mandatory deviation |
| EXC-005 | Exception audit | Request, decision, conditions, actor and time retained |
| EXC-006 | Conditional authorization | Follow-up tasks created when specified |
| EXC-007 | Reevaluate after material changes | Affected exceptions flagged for review |

### CLS — Closing/closure

| ID | Requirement | Acceptance criteria |
|---|---|---|
| CLS-001 | Schedule closing | Date/time/location saved |
| CLS-002 | Evaluate readiness | Required applicable work assessed |
| CLS-003 | Attorney override | Authorized permissible exception gives 'Ready with Exceptions', not false completion |
| CLS-004 | Record closing outcome | Actual closing and outcome recorded |
| CLS-005 | Post-closing work | Matter remains open for outstanding obligations |
| CLS-006 | Close matter | Either role may close with mandatory reason; incomplete obligations require disposition |
| CLS-007 | Reopen matter | Either role may reopen with mandatory reason |
| CLS-008 | Closure history | Actor, date and reason retained for all transitions |

### DSH — Dashboard

| ID | Requirement | Acceptance criteria |
|---|---|---|
| DSH-001 | Active matter overview | Buyer/Seller matters displayed |
| DSH-002 | My tasks | Filter by assigned staff member |
| DSH-003 | Deadline alerts | Upcoming and overdue visually distinguished |
| DSH-004 | Attorney approvals queue | Pending legal drafts and exceptions visible |
| DSH-005 | Blockers/readiness | Missing items and closing readiness visible |

### SEC — Security/reliability

| ID | Requirement | Acceptance criteria |
|---|---|---|
| SEC-001 | Internal authentication | Unauthorized access rejected |
| SEC-002 | Role authorization | Attorney-only decisions enforced on server |
| SEC-003 | Encryption | Protected in transit and at rest |
| SEC-004 | Audit | Material data/actions recorded with attribution |
| SEC-005 | Backup/recovery | Restore process documented and tested |
| SEC-006 | Historical integrity | Normal users cannot silently alter audit history |

## 9. Specific business conditions

| ID | Buyer condition | Expected behavior |
|---|---|---|
| BUY-01 | Condominium property | Activate condominium document tasks |
| BUY-02 | Chicago property | Activate code-violation check |
| BUY-03 | Retainer drafted/sent | Link DocuSign record and manual status |
| BUY-04 | Inspection/repair requests received | Initiate review |
| BUY-05 | Legal response draft | Attorney approval before authorized send |
| BUY-06 | Outstanding review issues | Remain active until resolved/dispositioned |
| BUY-07 | Financing deadline approaches | Reminders generated |
| BUY-08 | Not clear to close | Extension request process available |
| BUY-09 | Confirmed extension | Replace effective date, retain old date |
| BUY-10 | Closing complete | Start post-closing obligations |

| ID | Seller condition | Expected behavior |
|---|---|---|
| SEL-01 | Seller matter activated | Title and earnest-money tracking initialized |
| SEL-02 | Title ordered | Track provider/reference/status |
| SEL-03 | Earnest money outstanding | Receipt confirmation task stays active |
| SEL-04 | Municipality and units identified | Applicable property-document tasks activated |
| SEL-05 | Chicago 2+ unit property | Map-indicated zoning deadline, **subject to legal validation** |
| SEL-06 | Lien/title issue | Open resolution issue |
| SEL-07 | Buyer-side legal review received | Create attorney approval workflow for response |
| SEL-08 | Review objections unresolved | Keep related tasks active |
| SEL-09 | Pre-closing review | Evaluate title, zoning, water, survey, review as applicable |
| SEL-10 | Missing readiness requirements | Not Ready unless permitted Attorney override |
| SEL-11 | Closing complete | Confirm payment and final documents |
| SEL-12 | Post-closing issues | Maintain active follow-up |

## 10. Cross-cutting business events and exceptions

- **Canceled transaction:** record termination and reason, preserve history, stop routine reminders while preserving records.
- **Closing rescheduled:** update date and recompute only appropriately dependent internal milestones; flag contractual deadlines for explicit review.
- **On Hold:** never automatically suspend legal deadlines; show ongoing obligations.
- **Financing extension pending:** continue monitoring original effective deadline.
- **Rejected document:** move to outstanding state with reason.
- **Legal review iterations:** preserve every approval/revision round.
- **Title defects/inspection issues:** create individually assigned issues with resolution details.
- **Post-closing obligations:** keep matter open until dispositioned.
- **Reopening:** either role can reopen with reason; preserve prior closures.

## 11. Notification policy

Confirmed: in-app plus email; overdue reminders **every business day** until the deadline is resolved. Proposed but not yet approved: advance reminders at 7/3/1 days, 9:00 a.m. America/Chicago delivery, and definition of business days/holidays. No duplicate notifications for scheduler retries. Superseded deadlines stop old reminders. Email should minimize sensitive detail. Failed email deliveries should be logged; dashboard status persists regardless of delivery.

## 12. Financial status tracking (limited MVP)

Support manual confirmation of buyer retainer, seller earnest money, and seller closing payment status; include amount/date/reference where needed and optionally supporting receipt. **Not included:** collection, disbursement, merchant processing, trust ledger, bank reconciliation, or full billing/accounting.

## 13. MVP acceptance gates

| Gate | End-to-end test |
|---|---|
| GATE-01 | Buyer transaction from intake through conditional diligence, financing, closing and post-closing |
| GATE-02 | Seller transaction through title, earnest money, property requirements, legal review, clearance and closing |
| GATE-03 | Legal draft → Attorney revisions → approval of specific version → recorded external send |
| GATE-04 | Deadline change, notification schedules, repeated business-day overdue email/dashboard alerts |
| GATE-05 | Standard tasks plus custom tasks, conditional activation and justified Attorney exceptions |
| GATE-06 | Missing closing requirement blocks full readiness; authorized override yields Ready with Exceptions |
| GATE-07 | Both roles close/reopen with reason; history remains intact |
| GATE-08 | Access control, audit, document restrictions and backup restore verified |

No gate is marked passed merely by its inclusion in this PRD.

## 14. Open business decisions / validation required

1. Exact legal definition and classification of outgoing *legal* correspondence; treatment of Attorney self-approval.
2. Business-day/holiday calendar, email send hour, initial advance reminder timings, recipient/escalation rules.
3. Mandatory vs optional closing prerequisites and which legal/contractual requirements cannot be overridden.
4. Exact Chicago zoning, water, survey, unit-count, and local requirements; confirm accuracy and applicability with the Attorney.
5. Which documents must be retained after cancellation, closure and reopening; retention schedule.
6. Closure when residual obligations exist: require explicit disposition and clarify whether that itself is a legal exception.
7. Source-of-truth/backup policy for uploaded documents and off-platform DocuSign links; expected retention when links become unavailable.
8. Whether active existing matters must be migrated at launch and how legacy statuses are represented.
9. Backup retention, restore targets, audit retention, confidentiality roles and any matter-specific access restrictions.
10. Operational distinction between merely recording a sent legal communication and actually sending it externally.

## 15. Next design and technical work products

1. **Information architecture and UX flows:** Matter list, matter workspace, task board, deadline calendar, approval queue, documents, closing-readiness view, audit history.
2. **Domain model:** Matter, Party/Contact, Property, WorkflowTemplateVersion, Task, TaskDependency, DeadlineRevision, DocumentReference, CorrespondenceVersion, Approval, Issue, Exception, Notification, MatterEvent.
3. **Authorization and state-machine specifications:** role permissions, task transitions, approval/version checks, matter state transitions, readiness gate and overrides.
4. **Notification architecture:** business-day schedules, idempotent jobs, delivery failure handling, in-app event delivery.
5. **Architecture and implementation backlog:** application stack, data persistence, file storage, authentication, email service, monitoring, testing, migrations, and milestones.

## 16. Change control

This document is the **business baseline**, not final legal advice or an approved technical design. Version future changes with an owner, date, decision rationale, affected requirement IDs and acceptance tests. Maintain traceability from Buyer/Seller source operation IDs to application requirements and tests.
