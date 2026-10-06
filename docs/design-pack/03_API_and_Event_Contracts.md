# Application API and event contracts

Revision 1. These are proposed internal application interfaces. They are not tastytrade endpoints, and their idempotency guarantees do not extend automatically to the broker.

## 1. Identity and types

All objects have UUID IDs, environment (`readonly`, `sandbox`, `paper`, `shadow`, `live`), account ID, UTC timestamps, schema version and revision where mutable. Broker account numbers stay behind the server mapping. Decimal currency/price values are serialized as strings with an explicit currency/unit. Instrument IDs are stable internal keys; broker/vendor symbols are effective-dated mappings.

Read requests require an authenticated user authorized for the account. Commands require the appropriate capability, an application request ID and expected revision. Our own command API accepts `Idempotency-Key`; the gateway binds it to user, route and request-body hash and returns the same recorded command for a matching replay. Reusing a key with a different payload is a conflict. This mechanism does not mean the external broker deduplicates orders.

## 2. HTTP inventory

| Method/path | Request or query | Result and permission |
|---|---|---|
| `GET /v1/workspace` | Workspace ID | Account aliases, modes, user capabilities, nav/health summary |
| `GET /v1/accounts/{id}/snapshot` | Optional revision/as-of | Reconciled balances, positions, restrictions and known discrepancies |
| `POST /v1/accounts/{id}/reconcile` | Expected revision, reason | Durable reconcile job; never a blind financial retry |
| `GET /v1/accounts/{id}/capabilities` | — | Supported/tested products/actions and unresolved gaps |
| `GET /v1/instruments` | Search, type, underlying, cursor | Exact metadata IDs and versions |
| `GET /v1/options/chains/{underlying_id}` | Expiry, right, strike/delta slice, snapshot ID | Definition plus quote quality/age; nullable values |
| `POST /v1/market/snapshots` | Instrument IDs and required freshness | Immutable market snapshot reference and coverage results |
| `GET /v1/watchlists` | Workspace | Saved ordered instrument references |
| `POST /v1/watchlists/{id}/items` | IDs and expected revision | New list revision; user edit capability |
| `POST /v1/scans` | Typed filter AST and universe | Scan result/job and rejection/missing-data counts |
| `GET /v1/research/evidence` | Instrument/topic/as-of/cursor | Licensed evidence with availability timestamps |
| `POST /v1/research/briefs` | Context scope and evidence limits | Brief job and citations; no broker mutation |
| `POST /v1/analytics/payoff` | Exact legs, entry cash flow, assumptions | Expiry payoff/economic extrema and supported coverage |
| `POST /v1/analytics/scenarios` | Portfolio snapshot, hypothetical changes, shocks | Valuation/margin coverage and scenario contributions |
| `POST /v1/trade-proposals` | Structured draft | Proposed object; untrusted until quant/risk validated |
| `POST /v1/trade-intents` | Proposal/legs, account, snapshot, policy | Immutable intent candidate and validation results |
| `POST /v1/trade-intents/{id}/preflight` | Expected revision and price corridor | Broker dry-run, risk checks, reservation status, review expiry |
| `POST /v1/trade-intents/{id}/authorize` | Exact payload/policy hashes, expiry | Signed server authorization; approve capability |
| `POST /v1/trade-intents/{id}/dispatch` | Authorization ID, expected revision | Durable command ID; controlled writer owns submission |
| `GET /v1/trade-intents/{id}` | — | Internal lifecycle, raw broker status, quantities, risk reserve |
| `GET /v1/orders` | Account/environment/states/cursor | Active/recent orders and reconciliation state |
| `POST /v1/orders/{id}/cancel` | Expected revision, reason | Cancel command; completion must be observed |
| `POST /v1/orders/{id}/replace-plan` | Price/time-in-force, expected revision | Reviewed replacement candidate under broker capabilities |
| `POST /v1/orders/{id}/reconcile` | Reason | Inspect recoverable state, not resubmit |
| `GET /v1/positions/{id}` | Optional snapshot | Group/legs/lots, ownership, management and evidence |
| `POST /v1/positions/{id}/close-plan` | Quantity and execution policy | New closing intent, fresh risk analysis |
| `POST /v1/positions/{id}/roll-plan` | Candidate new legs/price | Linked close/open comparison and new authority requirement |
| `POST /v1/positions/{id}/ownership` | Owner/policy, expected revision | Audited management transfer; global risk remains |
| `GET /v1/risk/policies` | Account/workspace | Versioned policy hierarchy |
| `POST /v1/risk/policies` | Draft and expected parent | New policy revision; cannot mutate approved past version |
| `GET /v1/risk/snapshots/{id}` | — | Measurements, thresholds, provenance, unsupported coverage |
| `POST /v1/strategies` | Typed definition | Draft version/artifact hash |
| `POST /v1/strategies/{id}/versions` | Draft definition and predecessor | New immutable artifact |
| `POST /v1/strategy-versions/{id}/validate` | Dataset/capability scope | Static validation and missing dependency list |
| `POST /v1/strategy-versions/{id}/promote` | Target stage, evidence run IDs | Promotion candidate; live activation separate |
| `POST /v1/strategy-versions/{id}/activate` | Account, policy hash, budget, expiry | Explicit mode authorization and activation command |
| `POST /v1/strategies/{id}/pause-entries` | Reason, expected revision | Pause entry authority; manager state returned separately |
| `POST /v1/accounts/{id}/pause-entries` | Scope/reason | Account-level entry pause |
| `POST /v1/accounts/{id}/flatten-plans` | Selected inventory and constraints | Explicit per-position/order plan, unsupported residuals |
| `POST /v1/experiments` | Strategy/data/cost/split manifest | Research job with estimated cost and artifact IDs |
| `GET /v1/experiments/{id}` | — | Status/results/notices, engine versions and reproducibility |
| `POST /v1/experiments/{id}/cancel` | Reason | Cancel research job; no trade action |
| `GET /v1/journal` | Mode/strategy/date/cursor | Execution-derived entries with user notes |
| `POST /v1/journal/{id}/notes` | Text/attachments/revision | Appended note history |
| `GET /v1/inbox` | Severity/state/account/cursor | Durable incidents and deadlines |
| `POST /v1/inbox/{id}/acknowledge` | Expected revision | Acknowledgment only; unresolved action retained |
| `GET /v1/operations/health` | Scope | Observed process health and lag metrics |
| `POST /v1/assistant/runs` | Question, context scope and limits | Grounded read/draft tool run; no direct submit authority |
| `GET /v1/audit` | Object/correlation/time/cursor | Permission-scoped append-only evidence timeline |
| `POST /v1/exports` | Format/object scope | Download artifact with account access checks |

Use cursor pagination with a stable key and explicit snapshot/as-of when needed. Reject arbitrary caller-provided broker URLs. Long tasks return `202` and a job/command ID; browser polling/streaming follows status. Do not equate HTTP success with a filled trade.

## 3. Error and command results

Return a stable `code`, user-readable message, command/object ID, retry class, details and trace ID. Codes include `ACCOUNT_SCOPE_DENIED`, `ENVIRONMENT_MISMATCH`, `REVISION_CONFLICT`, `POLICY_BLOCKED`, `DATA_STALE`, `DATA_UNKNOWN`, `CONTRACT_UNSUPPORTED`, `AUTHORIZATION_EXPIRED`, `BROKER_REJECTED`, `BROKER_OUTCOME_UNKNOWN`, `RECONCILIATION_REQUIRED`, and `RATE_LIMITED`.

HTTP classes: 400 invalid shape; 401 missing app authentication; 403 capability denied; 409 revision/idempotency/policy conflict; 422 domain validation; 429 bounded app rate limiting; 503 service unable to prepare command. For a broker command accepted into our durable queue, an uncertain broker outcome is generally a command state, not an invitation to repeat the HTTP request with a new key.

## 4. Event stream

`GET /v1/events` via SSE is enough initially for browser updates; use an authenticated WebSocket if bidirectional subscription control is justified. Events are account/environment scoped and permission filtered. Never forward raw broker tokens/headers to the browser. Coalesce replaceable quote snapshots under backpressure, but never drop financial lifecycle/audit events. Slow clients resynchronize from snapshots and durable event cursors.

Envelope example (application-owned schema):

```json
{
  "event_id": "11111111-1111-4111-8111-111111111111",
  "schema_version": 1,
  "type": "execution.outcome_unknown",
  "account_id": "22222222-2222-4222-8222-222222222222",
  "environment": "paper",
  "aggregate_id": "33333333-3333-4333-8333-333333333333",
  "aggregate_revision": 7,
  "occurred_at": "2026-10-06T14:35:10Z",
  "received_at": "2026-10-06T14:35:10.080Z",
  "correlation_id": "44444444-4444-4444-8444-444444444444",
  "causation_id": "55555555-5555-4555-8555-555555555555",
  "source": "broker_adapter",
  "payload": {"intent_id":"33333333-3333-4333-8333-333333333333","risk_reserved_usd":"88.00","next_action":"reconcile"}
}
```

Topics: `market.quality_changed`, `account.snapshot_reconciled`, `account.discrepancy_opened`, `strategy.evaluated`, `proposal.created`, `risk.checked`, `risk.reserved`, `authorization.issued`, `execution.prepared`, `execution.submitted`, `execution.outcome_unknown`, `order.status_changed`, `execution.fill_observed`, `portfolio.position_changed`, `management.action_due`, `expiry.action_due`, `incident.opened`, `incident.acknowledged`, `incident.resolved`, `notification.dispatch_attempted`, and `worker.health_changed`.

Reconnection: client supplies its durable cursor; server replays retained events if permitted and available, otherwise sends `resync_required` with a fresh snapshot revision. The client never reconstructs account truth only from transient quote events.

## 5. Writer pseudocode

```python
async def dispatch(intent_id, authorization_id):
    # One account-bound broker gateway owns credentials and network mutations.
    prepared = await prepare_with_account_lock(intent_id, authorization_id)
    # Transaction checks account/mode, strategy/policy hashes, data age,
    # ambiguity state and reservations, then records an immutable payload.
    # Reconcile/drain old writer requests before any writer handover.
    await gateway.assert_current_writer(prepared.account_id, prepared.fence)
    await assert_current_dispatch_conditions(prepared)
    await record_submit_started(prepared)  # durable before network call
    try:
        result = await gateway.submit_once(prepared.payload)
    except OutcomeMayBeUnknown as exc:
        await record_unknown_preserving_reservation(prepared, exc)
        await schedule_reconciliation(prepared)  # never blind POST retry
        return
    await record_acknowledgment_or_confirmed_rejection(prepared, result)
    await schedule_fill_and_account_reconciliation(prepared)
```

The network gap after the last local check cannot be made atomic with a broker REST service. Record the limitations, lease handover policy and ambiguity path explicitly. Outbox retries for notifications are different from order-placement retries.

## 6. Data schemas and migration ownership

`05_database.sql` is a PostgreSQL starting migration illustrating constraints and durable objects. It is not a full finished ORM or production schema. `06_trade_proposal.schema.json` is a strict draft/proposal schema appropriate for an OpenAI structured-output contract; all values still require semantic validation. `07_strategy.example.yaml` shows a research/paper definition, not an approved live strategy or profitable recommendation.

Financial status transitions occur through domain commands that append events. Append-only audit and evidence roles need database permissions/triggers in the production migration. Keep raw broker JSON for schema drift and forensic review, with secrets removed. Record migration/adapter/schema hashes alongside research and activation manifests.

## 7. API test acceptance

Test same idempotency key/same payload; key reused with different payload; cross-account access; wrong environment; stale expected revision; expired payload-bound approval; risk race between two strategies; timeout after broker acceptance; cancel-fill race; stream reconnection with missing cursor; slow UI client; model-created unknown IDs; injection in an evidence document; price decimal/tick correctness; and forbidden capabilities omitted from client responses.

No application response should promise execution success until verified fills are recorded. No local simulation response should be mistaken for a live broker result.
