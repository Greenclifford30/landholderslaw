# Landholders Law — MVP Workflow Validation Guide

**Purpose:** Help the Product Owner, Operator, and Attorney decide whether the proposed buyer and seller workflows are ready to use as the basis for an internal MVP.  
**Status:** Review draft. Examples are fictional. Nothing in this guide establishes an Illinois legal requirement or authorizes a closing.  
**Source:** [Provisional workflow checklist](Landholders_Law_Provisional_Workflow_Checklist.md), [PRD](Landholders_Law_PRD_v1.0.md), and decisions recorded during the data-model review.

## 1. What we are validating

The proposed MVP gives internal staff a shared view of each transaction: who is responsible, what work and documents are outstanding, the dates staff have entered, and whether the firm considers the transaction ready for closing. Staff can also record the transaction closing and continue post-closing work before closing the file.

**Recommendation:** This is ready for a structured review with the Product Owner and Operator. It is **not yet ready for attorney validation as a final checklist or for production workflow seeding**: individual items, applicability rules, acceptable evidence, non-waivable items, and legal timing still need decisions. The source process diagrams should also be checked; the PRD says its operation lists are a prior interpretation of those diagrams.

The Product Owner should confirm that the workflow supports the firm's operating policy and MVP scope. The Operator should walk through the steps as daily work: who does each action, what they need to see, and what happens when information is missing. The Attorney must validate legal applicability, required and non-waivable items, evidence, deadlines, correspondence and exceptions. The same person may serve more than one of these review roles.

## 2. How to read the checklist

| Term | What it means in the proposed MVP | Example |
| --- | --- | --- |
| **Task** | Work assigned to someone. A required task is expected work, but it does not automatically become a closing blocker. | “Request the title commitment.” |
| **Requirement** | A separate item checked when evaluating closing readiness. | “An acceptable title commitment has been received.” |
| **Evidence** | The document, task, or financial confirmation staff explicitly accept as supporting a requirement. | The received title commitment, accepted by staff. |
| **Conditional** | Applies only if a fact or circumstance makes it relevant. Unknown applicability is flagged for review. | Condo documents when the property is a condominium. |
| **Exception** | Attorney authorization for a specific eligible unmet requirement, with a reason and any conditions. The item remains visibly unmet. | Proceed with an approved follow-up for an eligible missing item. |
| **Non-waivable** | An applicable unmet requirement that cannot be cleared through an internal readiness exception. The Attorney must decide which items, if any, have this designation. | No item is designated here pending attorney review. |

**Readiness labels:** “Not Ready” means a readiness check is unresolved or blocked; “Ready” means the applicable checks are satisfied; “Ready with Exceptions” means eligible unmet items are covered by effective attorney-approved exceptions and no other blocker remains. This is the firm's internal assessment, not a guarantee of legal compliance. An unvalidated template or missing authorized primary attorney makes the matter Not Ready.

## 3. Buyer walkthrough

For every row, the status shown is **provisional**, based on the earlier review. “Confirm” means the reviewers must agree on the actual task, timing, owner, applicability, and evidence before it is used as controlling workflow content.

| Stage and proposed operation | What the Operator would do | How it affects closing readiness | Reviewers should confirm |
| --- | --- | --- | --- |
| **Open the file** | Create a buyer matter, link the client and Illinois property, and assign a primary attorney. Enter known contract and deadline details; review tax records; prepare and track the retainer. | A signed retainer is a proposed separate readiness requirement. A task marked done does not by itself prove the signed retainer was received. | Which intake and tax steps are required? What signed-retainer evidence is acceptable? Are there cases where the retainer requirement does not apply? |
| **Conditional property checks** | Identify condo status and, where relevant, request condo documents. For Chicago property, track the proposed building-code check. | Condo documents are a proposed conditional readiness requirement. The Chicago check is a proposed required task; its readiness effect is not decided. | What facts make each step apply? Which condo documents count? Does the Chicago check affect readiness? |
| **Inspection and attorney review** | Assess incoming inspection or repair requests; record unresolved objections; prepare legal correspondence for attorney approval when needed. | An open issue is Not Ready until assessed. Either role can record whether an issue blocks readiness; an exception to a required item still needs attorney approval. | What constitutes a completed assessment? Which objections or decisions should block closing, and who supplies the evidence? |
| **Financing** | Determine whether a financing contingency applies. If it does, monitor it and enter the staff-confirmed effective deadline and its source. Track any proposed extension separately until confirmed. | Unresolved financing is flagged for staff assessment; it is not automatically a blocker in every matter. An unknown condition is flagged; whether that unknown can affect a closing requirement must be decided. | What information determines applicability and readiness impact? Who assesses it, and what documents or confirmations are needed? |
| **Closing and follow-up** | Record closing details and outcome; collect final title/settlement documents; assess and assign post-closing follow-up. | Pre-closing readiness and file closure are distinct. Final documents or follow-up may remain after the property closes. | Which items must exist before the transaction closes, and which can be completed afterward? What must be dispositioned before file closure? |

## 4. Seller walkthrough

| Stage and proposed operation | What the Operator would do | How it affects closing readiness | Reviewers should confirm |
| --- | --- | --- | --- |
| **Open the file and review title** | Enter known contract/property information; order and track a title commitment and its reference; review tax records. | Receipt of an acceptable title commitment is a proposed separate readiness requirement. | Who orders title? What evidence shows receipt and review? Does a title order need dedicated tracking beyond a task and reference? |
| **Earnest money** | Track receipt and record a financial confirmation. Several confirmations can support one requirement. | Confirmed receipt is a proposed readiness requirement. Staff explicitly accept the relevant confirmation(s); amount and date may be unknown under the current proposal. | Does the firm need the amount, date, proof, or confirmation of the total before readiness? Who is responsible for confirming receipt? |
| **Property-specific documents** | Assess zoning, water and survey separately; when applicable, track the work and request the documents. | Each applicable item is proposed as a separate document requirement. Unknown applicability is flagged. | Which properties and transactions need each item? What is acceptable evidence? Which items are non-waivable, if any? |
| **Attorney review and title issues** | Assess incoming requests; track objections; review and resolve applicable title issues; submit outgoing legal correspondence for attorney approval. | An open issue is Not Ready until assessed. Staff record whether an assessed issue blocks; a specific authorized exception may address an eligible requirement. | Which title findings need attorney assessment? Which must block, and how is resolution recorded? |
| **Closing and follow-up** | Review readiness, record closing details and outcome, confirm closing payment, collect final documents, and assess post-closing work. | Closing-payment confirmation and final documents may be post-closing work under the current proposal. Closing the transaction does not close the file. | Is the timing right for each item? What can remain open after closing? What must be dispositioned before file closure? |

The source process map mentions a two-week zoning timing for some properties. **The proposed MVP does not calculate that date automatically.** Staff review the matter and enter any applicable contractual deadline; the Attorney must validate the underlying rule before the firm relies on it.

## 5. Shared operating rules to demonstrate

1. **Create or activate:** A draft can be saved before all details are known. Activation requires a buyer/seller type, named client, Illinois street address and city, and an active primary attorney with access. The workflow can start on a published but unvalidated template; the matter remains Not Ready until that template version is attorney-validated.
2. **Own the work:** Each task has at most one accountable owner; it may be unassigned and visible for claiming. Staff can add custom tasks. Independent work can proceed in parallel; a task cannot be completed while its applicability is unresolved or a prerequisite remains unsatisfied.
3. **Track deadlines:** Either authorized role enters and changes effective contractual dates. A pending extension does not change the current date. A date-only deadline has no invented legal cutoff. Advance notices default to 7, 3 and 1 calendar days; overdue notices recur on firm business days. Putting a matter on hold does not suspend them. Transaction cancellation stops existing reminders; staff can explicitly reactivate reminders for continuing obligations.
4. **Manage documents:** Staff may upload a file or record an external link. DocuSign status is manually maintained; the app does not claim provider synchronization. Uploaded files must pass scanning before access. Staff explicitly accept evidence; changing or rejecting accepted evidence may reopen the requirement.
5. **Approve legal correspondence:** Operations or the Attorney prepares the package; an Attorney approves its content, subject, recipients, delivery method and attachment versions. An Attorney may approve their own draft. A material change needs a fresh approval; an Attorney must record why a changed revision is nonmaterial if the earlier approval remains effective. Sending happens outside the app and is recorded manually. An unapproved send can be recorded honestly as an incident; it is not retroactively represented as approved.
6. **Review readiness:** An unresolved relevant applicability question, unassessed open issue, unvalidated template, or lack of an authorized primary attorney can make the matter Not Ready. A specific unmet eligible requirement can have an attorney-approved exception; non-waivable items cannot. Replacing evidence, changing relevant facts, or withdrawing validation can require another review.
7. **Close and reopen the file:** Recording the property transaction closing does not close the file. Open obligations must be completed or explicitly dispositioned before file closure. Either role may close or reopen with a reason. Closed files are generally read-only for operational changes; permitted historical entries, hold/access actions, and incident recording have separate rules.

## 6. Scenarios for the validation session

Use these as walkthroughs, not as assertions that the example documents or legal rules apply in every transaction. For each, the Operator should describe the actual action they would take; the Product Owner should check the desired result; the Attorney should identify any legal or policy correction.

### Scenario A — Buyer with unknown condominium and financing information

A buyer file is activated with a named client, Illinois address, and primary attorney. Condo status and financing details are not yet known.

**Proposed result:** The file can be activated. Conditions remain unresolved and are flagged instead of being treated as “No.” If an unresolved condition could affect closing, readiness remains Not Ready. Staff later enter the facts and review the resulting work.

**Validate:** Are the minimum activation details sufficient? Who follows up on the unknown facts? What should make the matter Not Ready in this example?

### Scenario B — Seller awaiting a title commitment

The Operator has ordered title but has not received the commitment.

**Proposed result:** The order/track task and the missing title-commitment requirement are distinct. The requirement remains open until acceptable evidence is explicitly accepted or an eligible attorney-authorized exception applies. The Attorney must decide whether that item can ever be excepted.

**Validate:** Is receipt enough, or does the commitment also need a review? Who accepts it, and what would make it unacceptable?

### Scenario C — Extension requested before a deadline

A financing deadline is Friday. An extension to Tuesday is requested but not yet confirmed.

**Proposed result:** Friday stays the effective deadline and continues to be monitored. A request alone does not change the date. When a new date is confirmed, authorized staff enter it with its source and reason; the old date and reminders remain traceable.

**Validate:** Who confirms the extension and what sources are sufficient? Are reminder recipients and timing practical for daily operations?

### Scenario D — Missing certificate and closing exception

A seller requirement for a certificate applies, but the certificate has not been received before the planned closing.

**Proposed result:** The missing item remains open. If it is eligible for exception, staff request one with a reason and the Attorney decides. Approval can cover only identified items and may require follow-up. A relevant later change flags the exception for attorney review and the matter is Not Ready until reviewed. If the item is non-waivable, it continues to block.

**Validate:** Which items may be excepted? Who monitors any follow-up and when is the exception no longer needed? Which fact changes should trigger review?

### Scenario E — Transaction closes, file remains open

The property closes, but final documents and a follow-up task are outstanding.

**Proposed result:** Staff record the closing and its readiness snapshot. The file shows post-closing work and remains open. Staff complete or explicitly disposition remaining obligations before closing the file with a reason.

**Validate:** Are the listed follow-ups complete? Who confirms them? What is an acceptable disposition if an item cannot be completed?

### Scenario F — The system records an unapproved send

A legal letter was actually sent outside the app without the required prior approval.

**Proposed result:** Either role can record an incident without claiming approval. An Attorney reviews it or authorizes its disposition before file closure. It affects closing readiness only if staff mark it as a blocker. If discovered on a closed file, the incident can be recorded and reviewed; creating operational follow-up requires reopening.

**Validate:** Who handles the incident, how quickly, and should the firm retain the proposed readiness treatment? The app cannot prevent an off-platform send.

## 7. Decisions needing particular attention

These are the highest-impact items to resolve in the meeting; several are already recorded as provisional choices and should be challenged with real examples.

1. **Required work versus attorney control.** The current decision allows either role to cancel a required task with a reason, or change a required task or waivable requirement to optional with a reason, without attorney authorization. A separate readiness requirement remains independent; a non-waivable requirement requires attorney action before it can be made optional or canceled. **Confirm that this is intentional:** these actions can remove an expected control without using the attorney-waiver path. The earlier PRD says required-process exceptions need attorney authorization, so the Product Owner and Attorney should explicitly reconcile the policy before production.
2. **What blocks closing.** Confirm each proposed buyer/seller requirement, the treatment of unassessed issues and uncertain applicability, and which items are non-waivable. Resolve the Chicago building-code check and financing assessment in particular.
3. **Evidence and timing.** Define what is accepted, who accepts it, and whether the requirement applies before closing or only before file closure. Earnest-money readiness currently permits a confirmed record with unknown amount/date; validate that this is operationally sufficient.
4. **Exceptions and follow-up.** Confirm who requests and approves an exception, what conditions and triggering fact changes matter, and how follow-up is assigned and monitored. An internal exception must not be described as waiving an external legal obligation.
5. **Actual closing when Not Ready.** The dictionary recommends a truthful recording path for an actual closing that occurred while Not Ready, including a reason and attorney follow-up flag. Confirm the firm's authorization, escalation, and review policy; recording an event is not approval to proceed.
6. **Historical files and control scope.** Confirm how staff will enter work and correspondence from before launch, handle unknown dates, and distinguish an historical record from a current unapproved send. Confirm that the closed-file exceptions are practical.
7. **Operational load and scope.** Walk a real buyer and seller file from intake through closure. Identify duplicate steps, missing handoffs, default owners, dependencies, documents, and items that should be deferred. Validate the manual DocuSign, manual external-send, and notification behavior against actual practice.

## 8. Capture decisions

For each task or requirement, record the answers below. Split a grouped row whenever the answers differ between its constituent steps; do not turn a whole grouped row into a single seed task without review.

| Field to decide | Record |
| --- | --- |
| Workflow and phase | Buyer or seller; phase name |
| Operation | Plain-language action and PRD/diagram reference |
| Owner | Default role or unassigned; who may complete it |
| Applicability | Always, condition, or staff decision; required facts and handling of unknowns |
| Importance | Required or optional work; whether it separately blocks readiness; whether non-waivable |
| Completion / evidence | What proves the work is complete or the requirement is satisfied; who accepts it |
| Timing | Before closing, after closing, or before file closure; who enters any controlling date |
| Dependencies | Specific prerequisites, if any; avoid blocking unrelated work |
| Exceptions / follow-up | Whether permitted, who approves, conditions and trigger facts |
| Decision record | Confirmed / change needed / unresolved; reviewer, date, rationale and follow-up owner |

## 9. MVP validation outcome

The Product Owner and Operator can use the following as a meeting checklist; the Attorney must sign off on the applicable legal/policy content before production templates are validated.

- [ ] Walked one representative buyer file and one seller file, including an exception and post-closing work.
- [ ] Identified each required task, optional task, and separate closing requirement; split grouped entries where their rules differ.
- [ ] Agreed owners, triggers, evidence, dependencies, and treatment of unknown facts.
- [ ] Explicitly resolved the required-task cancellation/optional-setting policy in §7.
- [ ] Attorney reviewed applicability, deadline handling, non-waivable items, correspondence and exception policy.
- [ ] Confirmed the manual DocuSign and external-send boundaries match MVP expectations.
- [ ] Assigned an owner and follow-up date for every unresolved item, including source-diagram discrepancies.
- [ ] Product Owner and Operator confirm the flow is practical; Attorney validates the exact template version before readiness can show Ready.

**Decision record:** Product Owner: __________  Operator: __________  Attorney: __________  Date: __________  
**Outcome:** Ready for detailed template specification / Changes required / Further review required  
**Notes and owners:** ______________________________________________
