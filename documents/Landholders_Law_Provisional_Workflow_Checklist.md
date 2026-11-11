# Landholders Law — Provisional MVP Workflow Checklist

**Version:** 0.1  
**Status:** Provisional choices for attorney and Operations review; not validated legal requirements or seed data.  
**Sources:** [PRD](Landholders_Law_PRD_v1.0.md) and the data-dictionary review Q&A.

For a plain-language walkthrough and validation questions, see the [MVP workflow validation guide](Landholders_Law_MVP_Workflow_Validation_Guide.md).

Tasks represent work; requirements are separate readiness checks and need accepted evidence or an applicable authorized exception. A required task is not automatically a closing-readiness requirement. This is a grouped inventory, not a complete task list, legal interpretation, or approved applicability rule.

## Buyer

| PRD operations | Provisional task / requirement | Applicability and status |
| --- | --- | --- |
| B-03, B-07–08, B-11–14 | Capture contract and deadline details; retrieve/review tax records; prepare and track retainer | Required work, subject to attorney validation. Dates may be unknown at activation. |
| B-11–13 | Signed retainer | Separate readiness requirement with accepted evidence. |
| B-05–06 | Request/track condominium documents | Required task and separate readiness document requirement when condominium status applies; unknown status is unresolved. Attorney must identify acceptable documents and applicability. |
| B-09–10 | Check open building-code violations | Required task conditional on Chicago property; readiness impact awaits attorney review. |
| B-15–21 | Assess inspection requests and track unresolved objections | Required work; outgoing legal correspondence requires the normal approval process. |
| B-22–30 | Monitor financing contingency and enter its effective deadline | Required when contingency applies; unknown applicability flagged. Staff confirm the date and source. Unresolved financing is flagged for staff assessment rather than presumed to block every matter. |
| B-31–40 | Record closing details, collect final documents, assess remaining follow-up | Required work; post-closing work can remain open after the transaction closes. |

## Seller

| PRD operations | Provisional task / requirement | Applicability and status |
| --- | --- | --- |
| S-03–12 | Enter contract/property details; order/track title commitment; confirm earnest money; review tax records | Required work, subject to attorney validation. |
| S-05–07 | Receipt of title commitment | Separate readiness requirement with accepted document evidence. |
| S-09–10 | Earnest-money receipt | Separate readiness requirement with a recorded, accepted financial confirmation. Exact confirmation revision and acceptance rules belong in the data dictionary. |
| S-13–21 | Zoning, water certificate and survey | Determine applicability separately for each; flag unknowns. Each applicable item has a required tracking task and separate readiness document requirement. Attorney must validate applicability and acceptable evidence. |
| S-16 | Map-indicated zoning timing | Flag for staff review; staff enter any applicable contractual deadline manually. No automatic two-week calculation. |
| S-22–32 | Assess incoming requests, track objections, and review/resolve applicable title issues | Required work; outgoing legal correspondence requires attorney approval. Each issue is assessed for readiness impact; no blanket rule that every title issue blocks. |
| S-33–48 | Review readiness, record closing details/outcome, confirm closing payment, collect final documents and assess post-closing work | Required work; payment confirmation and final documents may be post-closing obligations. |

## Shared decisions and validation

- An unassessed issue blocks readiness until either authorized role records its impact. Capture the assessment, actor, time and reason. A required-item exception still needs attorney approval.
- Non-waivable designations remain for attorney validation. Do not assume an internal exception changes an external legal or contractual duty.
- Template publication and attorney validation are separate. A published, unvalidated version can be used for activation, but readiness is **Not Ready** with reason “Template awaiting attorney validation.” Validation applies to the immutable version. Withdrawal makes affected matters Not Ready and flags them for attorney review. Retirement prevents new use but does not itself withdraw validation; existing matters remain on their version.
- Attorney and Operations must validate each task, readiness item, applicable condition, evidence criterion, dependency, non-waivable designation and status before production use. The conditional rules and workflow diagrams in the PRD are not automatically authoritative.

## Product Owner review — legal and firm-policy decisions

Use this section to prepare the Product Owner discussion and capture the firm's decisions. **All items below are pending review**, even where the existing documents describe a proposed workflow or a previously recorded operating decision. The Product Owner confirms the desired operating process and identifies the decision owner; the responsible Attorney must approve legal applicability, duties, deadlines, correspondence controls, and exceptions. Operations should confirm that the resulting process can be performed. Record any change to an existing decision and its rationale rather than treating these questions as already approved.

For each item, record the decision, scope or exceptions, decision owner, approver, and approval date in the [workflow validation guide](Landholders_Law_MVP_Workflow_Validation_Guide.md) or the firm's decision log. Mark it **approved**, **changes requested**, or **deferred**; identify follow-up and a due date for anything deferred. Update the checklist, data dictionary, workflow definitions, and acceptance tests when a decision changes. Do not seed a legal rule or rely on it in production solely because it appears below.

| Review | Decision to cover with the Product Owner | Attorney / firm confirmation needed |
| --- | --- | --- |
| ☐ | **Buyer and seller workflow:** For each item in the Buyer and Seller sections, is it a required task, a separate closing-readiness requirement, optional, or not applicable? Who owns it and when should it be completed? | Approve each task and readiness item, including when it applies, required timing, permitted exceptions, and whether the source process maps are accurate. |
| ☐ | **Property-specific requirements:** How should staff identify and follow up on condo documents, Chicago building-code checks, zoning, water certificates, and surveys? | Determine applicability by property and transaction, acceptable documents, any legal or contractual deadlines, and readiness impact. Confirm or correct the source map's proposed two-week zoning timing; the MVP does not calculate it automatically. |
| ☐ | **Evidence and financial confirmations:** What evidence is sufficient for a signed retainer, title commitment, earnest money, and other closing items? Who reviews and accepts it? | Decide whether receipt alone or substantive review is required; whether amount, date, proof, or total receipt must be known; and when replacement or rejection requires reassessment. Financial confirmation is not a trust ledger or payment system. |
| ☐ | **Closing readiness and exceptions:** Which unmet or unresolved items block closing readiness, which can be excepted, and which are non-waivable? What facts invalidate an exception? | Approve each non-waivable designation, eligibility for attorney-approved exceptions, required justification and follow-up, and re-review triggers. An internal exception does not itself change an external duty. |
| ☐ | **Required work and cancellation:** Should either authorized role retain the proposed ability to change a required task or waivable requirement to optional, or cancel a required task, with a reason? | Explicitly approve or change these controls: they can bypass an attorney-waiver path. Confirm attorney-only control of non-waivable status and whether a separate readiness requirement still blocks. |
| ☐ | **Deadlines, extensions, and reminders:** Who enters and confirms effective dates and sources? What should staff do with a pending extension, unknown cutoff, on-hold matter, or canceled transaction? | Approve the distinction between a request and a confirmed extension, date-only handling, continuing obligations after cancellation, and the firm business-day/holiday calendar. Confirm recipients, escalation, proposed 7/3/1-day advance notices, 9:00 a.m. send time, and business-day overdue recurrence. These notification defaults are not legal deadline calculations. |
| ☐ | **Legal correspondence:** Which outgoing communications require review, and may an Attorney approve their own draft? | Define legal correspondence, approve the review and send-record process, and determine what makes a revision material, when prior approval may be extended, and how approval is revoked. The MVP records external sends; it does not prevent off-platform sending. |
| ☐ | **Unapproved sends:** How should staff report a communication already sent without required approval, and who follows up? | Approve attorney review or authorized disposition before file closure, readiness-blocker treatment, required notes and follow-up, and the rule against portraying the send as approved after the fact. |
| ☐ | **Closing, cancellation, and file closure:** What work may remain after the property closes? What must be completed or explicitly dispositioned before closing or reopening the file? | Confirm who may close/reopen, required reasons and dispositions, how canceled transactions and continuing obligations are handled, and whether any obligations require attorney authorization. |
| ☐ | **Existing matters and historical records:** What legacy information should staff enter, and how should unknown dates, senders, approvals, and past readiness be represented? | Approve the historical cutoff and attestation process, permitted entries on closed files, and the rule that unknown facts must not be presented as known or approved. |
| ☐ | **Retention, confidentiality, and legal holds:** What records and file versions must be preserved, for how long, and who may access restricted matters? | Approve retention and disposal policy, hold placement/release authority, access and recovery procedures, and how to handle external links or files that cannot be preserved. Database hold records alone do not place or verify an object-storage hold. |
| ☐ | **Template approval and change control:** Who reviews each buyer/seller template version, and what happens if a previously approved version is withdrawn? | Confirm the proposed separation between publication and attorney validation, treatment of matters using an unvalidated or withdrawn version, and the procedure for approving revised content. |

**Review outcome:** ☐ Approved for implementation and attorney-validated workflow seeding  ☐ Changes requested  ☐ Deferred

**Product Owner:** ____________________  **Attorney approver:** ____________________  **Operations reviewer:** ____________________  **Date:** __________

**Decision log / follow-up:** ______________________________________________________________________________________
