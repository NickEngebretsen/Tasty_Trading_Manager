# Implementation handoff

Build the system in this specification incrementally. The existing deliverables are design assets, starter contracts and a local prototype, not a connected trading engine.

## Repository layout

| Path | Responsibility |
|---|---|
| `apps/web/src/shell/` | Account/environment chrome and navigation |
| `apps/web/src/features/portfolio/` | Groups, positions, ownership and inspectors |
| `apps/web/src/features/trade/` | Chain, builder, review and lifecycle |
| `apps/web/src/features/research/` | Markets, evidence, experiments and replay |
| `apps/web/src/features/risk/` | Limits, scenarios, margin and expiry actions |
| `apps/web/src/features/automation/` | Strategy recipes, versions and promotions |
| `apps/web/src/features/operations/` | Incidents, connection ages and recovery |
| `services/trading/domain/` | IDs, commands, value types, invariants and events |
| `services/trading/broker/` | OAuth, capabilities, REST/stream adapters and broker gateway |
| `services/trading/market/` | Instruments, subscriptions, quality, calendars and snapshots |
| `services/trading/quant/` | Pricing, payoff, Greeks, indicators and scenario engines |
| `services/trading/risk/` | Policies, authorization, reservations and decisions |
| `services/trading/execution/` | Immutable prepared commands, writer lease and reconciliation |
| `services/trading/portfolio/` | Ledger, virtual lots, broker truth and performance |
| `services/trading/strategy/` | Typed AST, evaluator, sizing and management plans |
| `services/trading/ai/` | Context packs, typed read/draft tools, outputs, evals and costs |
| `services/trading/research/` | Engine adapters, manifests, experiments and replay |
| `services/trading/communication/` | Durable inbox, outbox, channels and escalation |
| `services/trading/api/` | Authenticated HTTP/SSE routes and DTO mapping |
| `workers/` | Ingestion, strategy, execution, AI, research and notifications entrypoints |
| `contracts/` | JSON/OpenAPI schemas and generated frontend types |
| `db/migrations/` | Production migrations, constraints, grants and append-only policy |
| `tests/fixtures/` | Redacted recorded contracts and lifecycle cases |
| `tests/contract/` | Certification and provider contract verification |
| `tests/domain/` | High-impact numeric, authorization and reservation properties |
| `tests/faults/` | Submit boundary, handover, reconnect and restore tests |
| `infra/` | Environment templates, observability, secrets and recovery |

## First vertical slice

Implement a read-only account connection end to end: TokenManager → account discovery → instruments/positions/balances/orders → account stream → normalized snapshots → reconciliation → Portfolio/Overview/Operations UI. Record raw redacted evidence and expose timestamp/reconciliation state. Support a manual broker trade entering Unassigned and a revoked connection refusing new work. No live write credentials in this slice.

Next implement one stock and one ordinary unadjusted option trade analysis: snapshot → exact instruments → payoff/quant → policy checks → local paper intent → simulated order lifecycle → portfolio/journal. Add broker certification preflight/submission only after the typed gateway, reservation and UNKNOWN recovery path are complete.

## Implementation instructions

1. Read the entire blueprint and source register before selecting APIs. Validate exact current schemas; documentation conflicts are explicitly retained.
2. Keep server-owned account identity, money, quantity, symbols and authorization authoritative. The UI cannot be the only risk gate.
3. Share a single typed strategy AST and evaluator across replay, paper, shadow and live. Do not implement a visually similar but separate live rules engine.
4. Implement Decimal/tick/quantity conventions before analytics become execution inputs. Every Greek and event field needs units and timestamp semantics.
5. Keep broker submissions single-writer and durable. Outbox/task retries cannot silently repeat a financial POST.
6. Preserve raw broker status, internal intent state and verified filled quantity separately.
7. Never release an ambiguous reservation by timeout alone; do not automatically fail over an account writer until in-flight commands are reconciled.
8. Put the OpenAI assistant behind account-scoped read/draft tools. No broker write tokens, arbitrary URLs or unrestricted shell access in the model interface.
9. Treat absent calendar/data/contract coverage as UNKNOWN. Make unsupported features inspectable and blocked.
10. Match the prototype's information hierarchy and interaction intent, then implement the full screen specification. Do not leave synthetic prices or return charts in a production UI.
11. Distinguish a software exit from a broker-resident protective order. Verify bracket behavior by product and partial-fill state.
12. Use the backlog's dependencies and test matrix to select the next slice. Record source/schema/test evidence for each enabled capability.
13. Ship narrow functional slices. Avoid a placeholder service fleet, dozens of unconnected screens, or untested broad strategy automation.
14. Report supported functionality, validation, limitations and what remains disabled after each release.

## Proposed OpenAI call pattern

Use the current official Responses API and supported configurable model. Load `06_trade_proposal.schema.json` as the strict output schema, and provide only curated context/evidence plus allowed read/draft tools. Function tools also use strict schemas. The application handles tool-call dispatch with account permissions, returns trusted results to the model, then validates the final proposal semantically.

Conceptual request fields: `model=<validated configuration>`, `input=<context and question>`, `tools=<strict function definitions>`, `text.format={type: json_schema, name: trade_proposal, strict: true, schema: <loaded schema>}`, and retention configuration appropriate to the selected features. Exact current SDK/request syntax is verified before coding. No model invocation or key setup is required for this design package.

## Definition of done for the first live capability

The exact account/environment, product, order type and management path have contract evidence; the policy envelope and reviewed intent are durable; sizing and portfolio checks include existing and pending risk; submit uncertainty and cancel/fill races recover safely; the broker's true state reconciles with the app; independent outage alerts work; restart/restore cannot replay old trades; and the user explicitly activates the concrete limited authority. Strategy edge remains a separate research decision.
