# Screen and interaction specification

Trade Workbench — revision 1, October 6, 2026

The accompanying HTML is an explorable design prototype with synthetic data and local interactions. It has no account connection, OpenAI calls, outgoing messages, persistent backend, or trade routing. Production behavior is specified here and in the blueprint.

## 1. Application shell

Desktop has a compact left navigation, a top account/environment bar, a central work area, contextual inspectors and a small system footer. Put the current account and mode on every trade-related screen. The central area shows one primary task at a time. Advanced information is available through tabs, expandable rows and inspectors, without disappearing from the underlying risk calculations.

Navigation groups: Today (Overview, Inbox), Markets (Markets, Options, Research), Trade (Trade builder, Portfolio, Orders), Automate (Strategies, Research Lab), Review (Risk Lab, Journal), System (Assistant, Operations, Settings). A command palette searches symbols, positions, strategies, orders and actions. Keyboard commands can navigate or open review; they never submit a live trade without its normal authorization flow.

At 1440 px and wider, show a 200–224 px navigation and a 300–360 px inspector when opened. At 1024 px, navigation is narrower and inspectors overlay or replace a column. On tablet, use compact navigation and stacked analytical panes. At 320–480 px, use a page selector or bottom destinations for Overview, Portfolio, Inbox and More; reveal dense chain/order tables through responsive layouts. Do not hide active risk or environment labels on mobile.

Top bar fields: product, current workspace, account alias and masked ID, currency, execution mode, current session with timezone, data age, connection status, and Pause entries. Keep Cancel orders and Flatten behind a clearly labeled control menu that shows distinct consequences. A pause has its own backend status, progress and result.

Every financial number includes currency or unit, basis, timestamp and an inspection path. Status must be conveyed in text as well as color. Green does not always mean safe; short-option theta and profit are not overall risk classifications.

## 2. Visual system

Use restrained neutral surfaces, strong legible text, tabular numerals and a single calm accent for navigation/actions. Positive/negative P/L colors are semantic and accompanied by signs. Warning amber means attention; danger red means a blocked action or active incident. Distinguish read-only, paper and live using explicit labels and icon/text cues rather than theme color alone.

Desktop type hierarchy: 24–28 px screen title, 18–20 px key value, 14 px normal content, 12 px secondary labels. Table density is user-configurable. Maintain visible focus, accessible labels, sufficiently large touch targets and usable zoom. Charts have directly labeled axes/units and accessible textual summaries. A compact sparkline is not a replacement for a detailed return report.

Provide light/dark modes, respecting system appearance, and a reduced-motion setting. Avoid flashing quote colors and live-region announcements on every tick. Show only material changes to assistive technology.

## 3. Shared states and interaction contracts

All screens define first-load, refreshing, populated, empty, stale, partially available, forbidden and disconnected states. First-load uses bounded skeletons; refresh preserves prior data with age labels. Never replace unavailable quotes with zeros. An empty table says why it is empty and provides a relevant next action.

Selection follows a stable instrument ID. Filters and preferences can be saved independently of the current market snapshot. A user cannot accidentally carry a trade ticket from a paper account to live by switching the global account. Switching account/mode invalidates the ticket's approval and requires re-review.

Buttons mutate via typed commands with request IDs, server acknowledgment and observable completion. Disable duplicate commands in progress. After a timeout, show Unknown outcome for broker mutations and inspect/reconcile; do not show a generic Retry submission button.

Dangerous actions explain the concrete account, orders/positions affected and policy. Pausing entries can be fast and reversible. Flattening requires a specific plan because it can close useful hedges and create residual risk. Review is the primary last step for a new supervised trade.

## 4. Overview

Primary question: what is happening now, what needs action, and is the system operating correctly?

Show account value and cash/available capacity, daily cash-flow-adjusted P/L, authorized automated risk used, active strategy modes, and a compact attention queue. The queue prioritizes unresolved orders/assignment ahead of optional proposals. Include a short portfolio preview and recent execution/decision timeline. Show Next scheduled work with market timezone. Avoid a dashboard of every indicator and a percentage-complete concept.

Main actions: inspect attention item, open portfolio, review proposal, pause entries, inspect system status. Each opens the underlying object rather than a generic report. A stopped strategy can show its management-only positions and why new entries are suspended.

Data: reconciled account snapshot, portfolio risk snapshot, inbox aggregates, worker/mode status and latest decision events. Refresh from server events; risk-dependent actions require an acceptable snapshot age. Acceptance: the user can identify an UNKNOWN order, see whether existing exits remain managed, and navigate to the related evidence within two actions.

## 5. Markets workspace

Left: saved watchlists or scan results with symbol, price, percentage change, volume/liquidity, data age and event flag. Center: price chart with volume and selected indicators. Below: fundamentals/events or relative performance. Right inspector, when useful: linked research and supported options expirations.

Filters include universe, price, volume, spread, volatility, trend, sector and upcoming event; advanced filters use a typed expression builder. A saved screener records the exact feature definitions. Show how many candidates were removed for missing data rather than merely reporting a result count.

Clicking a symbol synchronizes chart, chain and evidence views, with a consistent symbol-color link if multiple panes exist. Chart cursor information is a historical value, not an executable quote. Drawing/indicator alerts produce draft alert definitions. Trading from the chart opens a ticket, never an immediate account mutation.

Chart preferences: daily/intraday interval, adjusted/unadjusted historical basis, regular/extended session, indicators, visible range, benchmark and timezone. Use a properly licensed chart library with our own data adapter. Crosshair tables show series timestamps, values and missing observations.

Acceptance: changing the selected symbol changes all linked panes; stale input is visible; scan criteria and selected row can be reproduced from a snapshot.

## 6. Research and thesis workspace

Tabs: Brief, Evidence, Financials, Events and Thesis. A brief begins with sourced facts, recent changes, alternative explanations and unknowns. Each factual statement links to a filing/news item and publication time. Forecasts and hypotheses are visually distinct from facts.

Evidence table: source, title, event/publication time, ingestion time, permitted excerpt, relevant instruments, reliability notes and extraction version. The user's thesis records expected catalyst, expected horizon, invalidation, decision to take no action, and optional comparison to a benchmark. Changes append to thesis history.

Trade action creates a draft based on a thesis; numerical payoff comes from the quant engine. Research approval does not grant trading authority. Source conflicts become review items. If event coverage is incomplete, the product says Calendar coverage incomplete instead of No earnings risk.

Acceptance: every assistant price/financial fact resolves to an input; a later revised filing cannot overwrite the earlier evidence used by a historical trade.

## 7. Options chain

Top: underlying quote with age, expiry selector, DTE, contract/session metadata, and filters. Chain centered on strikes: calls on left and puts on right for wide screens; on mobile show one right at a time with strike retained. Columns available: bid/ask, spread, size, last-trade age, volume, OI availability date, delta/gamma/theta/vega, IV, intrinsic/extrinsic, and adjusted-contract marker.

Default density exposes bid/ask, delta, IV, volume/OI and strike. Additional columns are configurable. Selection uses explicit Buy/Sell buttons, with action and leg summary visible; clicking a price may prefill a ticket but must not submit it. Long/short legs have both text and color. Adjusted contracts show exact deliverables or an unsupported badge.

An IV view shows skew and term structure with source/method. OI is not falsely shown as live. Estimated probability metrics disclose methodology. An unavailable Greek remains unavailable; it is not silently inferred from an unrelated contract.

Acceptance: selection preserves the exact broker contract ID and effective metadata; the trade builder cannot route a stale or unsupported chain row.

## 8. Trade builder

Sections: thesis/intent, instrument and leg table, order pricing/quantity, payoff/scenarios, portfolio impact, management plan, preflight and review. On desktop the leg/order pane and analytics pane sit side by side; on mobile the ticket leads, followed by economics and limits.

Leg row fields: broker-resolved symbol, expiry, strike, right, Buy/Sell and Open/Close, ratio/quantity, quote with age, adjusted flag, editable action and remove. Quantity must respect steps and ratios. Changing a leg invalidates earlier risk checks. Template controls include stock, long call/put, debit/credit vertical, covered call, cash-secured put, condor, calendar/diagonal, butterfly and custom supported structure.

Ticket fields: account/mode, net Debit/Credit, limit, tick rule, time in force, execution policy and latest approved price corridor. Show total cost/credit in dollars and number of contracts separately. A premium price such as 0.85 is not the total $85 contract cost. Quantity is never confused with shares delivered.

Payoff view: expiry curve, break-even points, modeled maximum gain/loss with applicability conditions, fees, scenario cursor, and before-expiry repricing controls for underlying/time/volatility. Before-expiry uses full declared valuation; do not label an expiry-only calculation as a live option forecast. Greeks and scenario tables support detail inspection.

Portfolio impact: current versus after-trade cash, buying-power requirement, modeled risk, worst tested scenario, delta/vega/gamma, concentration and pending reservation. Check results are individually inspectable. Any unavailable scenario coverage is shown.

Management plan: owner, targets, invalidation/stop basis, internal expiry close deadline, event policy, maximum hold, and whether protection is a verified broker order or a software rule. Review is unavailable until required checks pass or declared supervised warnings are accepted.

Acceptance: changing quantity updates all dollar amounts; a $100 policy rejects an indivisible $380-risk spread; changing account invalidates the ticket; UI and server give the same reason for a blocked trade.

## 9. Trade review and approval

Review presents an immutable, concise snapshot: account/mode; action/quantity and all legs; debit/credit and price corridor; total cost including fee estimate; conditional maximum loss and assignment obligation; portfolio impact; specific passed/failed/unknown checks; management owner; event dates; broker dry-run warnings; expiration time of approval; and data timestamps.

Primary action in supervised live is Approve this trade with precise identity. The server approves the payload hash and rechecks at dispatch. Approval succeeds as an application command; it is not the same as a fill. Show Submitted, Working, Partial fill, Unknown, Rejected or Filled as actual lifecycle outcomes.

Automatic mode review focuses on the policy envelope: strategy version/hash, account, structures, universe, schedule, sleeve limit, per-trade and global caps, price/repricing policy, management/exit exceptions and expiry. Primary action is Activate this strategy within these limits. No arbitrary future change inherits that authorization.

## 10. Portfolio

Top summary distinguishes broker net liquidation, internally computed mark P/L, estimated liquidation P/L, settled cash and margin capacity. Main table groups by economic strategy or underlying with account, owner/mode, quantity, basis, mark, unrealized/realized net P/L, max modeled risk, expiration, event/management status and update age.

Expandable groups show every leg, fill, fee and attribution lot. Filter by account, strategy, underlying, sleeve, expiry, owner, supported/unsupported and manual/automated. A separate exposure lens shows factor/sector/underlying and cannot silently omit unsupported positions.

Actions: inspect, simulate close/roll/hedge, transfer virtual attribution with audit, take manual management ownership, and export. Close opens a reviewed closing intent. Roll comparison shows closing P/L and costs separately from the new position. A position inspector links thesis, risk, management policy, orders, executions, events and journal.

Acceptance: positions opened in the broker app appear promptly in Unassigned; they count toward global risk; a strategy cannot accidentally close another owner's holdings.

## 11. Risk Lab

Tabs/lenses: Limits, Exposure, Scenarios, Margin, Expiration and Liquidity. Scenarios have current/hypothetical portfolio selectors and assumptions for underlying/factor moves, IV/skew shifts, time, spreads and rates. Initial view is a small scenario table with a dominant payoff/risk visualization, not dozens of opaque gauges.

Results: dollar/percent portfolio impact, affected positions, largest contributors, buying-power headroom, assignment cash, model coverage, timestamp and method. Add/remove/increase/decrease positions in a hypothetical portfolio without changing real holdings. Show current and proposed on the same scale. Historical scenarios specify data dates and applicability.

Limits show actual measurements, thresholds and status with units. A budget ceiling is not an allocation target. A candidate hedge lists risk reduction versus cost and new exposures; reducing delta is not necessarily reducing every risk.

Prototype scenario sliders use an explicitly labeled approximation on synthetic data. Production large-shock analysis requires full nonlinear repricing with supported contract metadata.

Acceptance: a scenario exposes unsupported positions; a closing protective leg can be flagged as risk-increasing; input assumptions and calculation version are exportable.

## 12. Strategies and visual editor

Strategies list: name, immutable version, account, environment, lifecycle stage, budget used/remaining, next evaluation, managed positions, last decision and reason, incident status and entry mode. Pause entries is separate from Stop management. A paused strategy's managers remain visible.

Detail/editor sections: Universe, Entry, Contract selection, Sizing, Execution, Management, Events, Risk, Schedule, Evidence, Version diff and Promotion. Visual recipes use typed branches with PASS/FAIL/UNKNOWN outputs. A side inspection of a selected branch shows actual values and timestamps for a recent decision.

For entry criteria define conjunction/disjunction, lookback, operator, units and missing-data policy. Contract selection supports expiry interval, target delta/strike offset, width, liquidity and adjusted exclusions. The editor validates dependency availability and current account product support. The code view is a generated typed AST/configuration, not a separate inconsistent implementation.

Editing a live strategy creates a draft revision. Users see semantic changes and affected authorizations. Promote opens an evidence checklist linked to actual runs; authorization is bound to the version. A cloned strategy receives a new ID and zero live authority.

Acceptance: visual/code views produce equivalent AST; UNKNOWN data blocks default entry; changing a parameter cannot mutate an active version invisibly.

## 13. Research Lab and backtest replay

Experiment setup: frozen strategy/version, universe, dataset manifest, time range, warm-up, initial capital, account rules, commission/interest, fill/slippage scenarios, event/assignment assumptions, holdout partition and benchmark. A cost preview precedes large downloads or runs.

Results: equity/drawdown curves, gross/net/benchmark comparison, costs, statistical uncertainty, regime breakdown, distribution and trade-level logs. Separate training/validation/holdout and paper/live returns. Comparison views use consistent capital, dates, costs and definitions. A broker backtester result is labeled with engine/version and assumptions rather than flattened into our engine's identity.

Replay: play/step through decision events, display the market/account snapshot visible at that time, show rules and order outcomes, and explain blocked decisions. It must not load a current quote into a historical replay. Navigation to an individual trade restores its environment/time context.

Promotion action creates a locked candidate and links required prospective observation. A compelling curve alone cannot activate live trading. Synthetic prototype result curves are marked Synthetic demonstration, never Historical performance.

## 14. Orders and execution inspector

Blotter columns: environment/account, internal intent, broker ID, strategy version, instrument summary, order type, net price/effect, submitted/fill/remaining quantity, raw broker status, internal state, update time, reserve and incident. Filters distinguish all current active orders from today's history; provider route names do not determine our UI meaning.

Inspector timeline: proposal, market/account snapshot, rule decisions, risk reservation, dry-run, authorization, writer claim, submit attempt, acknowledgment/unknown, broker status updates, fills, costs and reconciliation. A fill records exact quantity, price, timestamp and execution identifier; arrival/decision benchmarks make slippage inspectable.

Actions depend on verified capabilities and current state. Cancel is a requested operation until confirmed. Replace shows new price corridor and renewed checks. Unknown outcome offers Reconcile and Open broker, not Blind retry. Multiple selected cancels report per-order results.

Acceptance: an acknowledgment timeout preserves reservation; cancel-fill race displays actual resulting inventory; reopening the page cannot create another intent/submission.

## 15. Inbox and notifications

Sort actionable items by severity/deadline. Categories: order ambiguity, risk, expiration/assignment, approval, data/account health, research coverage and informational. Each item includes facts, current action taken, ownership, deadline/timezone and a route to the related object. Distinguish new, acknowledged, action in progress and resolved. Acknowledged is not resolved.

Alert configuration includes thresholds/conditions, event dedupe interval, severity, channel selection, sensitive-field redaction, quiet hours and escalation. Test channel controls send only an explicitly initiated test during actual implementation; this prototype simply changes local settings.

Acceptance: urgent incident recovery does not close a still-unreconciled order; duplicates collapse into one incident with an event history.

## 16. Journal and reviews

Generate a journal entry from the full trade provenance. Show thesis, intended holding horizon, risk budget, entry/exit decision, fills/costs, management changes, rolls, outcome and benchmark. Add the user's notes and screenshots as attachments with timestamps and retention rights. Editing a note does not alter the initial thesis or executed payload.

Analytics group by strategy version, setup, instrument, time, regime, owner/mode and cost. Include expectancy, R-multiple based on the actual initial defined risk, MAE/MFE, win/loss distributions and process-rule adherence. Missing/highly uncertain risk denominators make R-multiple unavailable. Keep paper, backtest and live statistics separate by default.

Weekly review describes evidence and uncertainty, with candidate changes as drafts. It cannot silently retune a strategy because of a losing streak.

## 17. Assistant

Conversation is adjacent to an explicit context selector: account/environment, selected position/strategy and evidence timestamp. Example prompts: Explain my current risk; Compare this debit spread with stock; Why was this entry blocked?; What changes if volatility rises?; Draft a strategy using these rules.

Responses include facts, source/evidence links, quant-tool figures, uncertainty/missing inputs, and draft objects. Action chips open a real proposal/risk/strategy object rather than executing an instruction from prose. Retrieved text never changes tool authority. Streaming responses can show progress but no financial action is taken until an authorized application command exists.

Prototype responses are scripted examples, visibly labeled. Production includes model/prompt/schema trace and usage in an expandable audit view, without exposing secrets.

## 18. Operations

Health view shows quote stream, account stream, writer lease/worker, database, risk computations, reconciliation, model service/budget and notifications. Each status reports observed time and a useful metric. Show in-flight and UNKNOWN commands separately from ordinary queued jobs.

Incident actions: inspect timeline, reconcile account, reauthenticate connection, pause entries, inspect broker, restore monitoring. Restart/reconnect never implies permission to replay financial commands. Simulation controls exist only in developer/paper environments and are clearly separated from production controls.

An independent heartbeat monitor detects total application failure. A green dashboard within a stalled process is insufficient health evidence.

## 19. Settings and onboarding

Onboarding sequence: create workspace; select paper/read-only mode; securely configure broker connection; discover accounts/products; select data feeds and acknowledge required usage rights; define risk policies; set notifications; validate connection/recovery; create first strategy draft. Live activation is an explicit later action on a concrete policy/account.

Settings sections: profile/timezone, accounts/access, data entitlements and quality policies, risk profiles/sleeves, execution defaults, model workflows/budgets, notifications, storage/export, audit/security and system capabilities. Secret displays show only configured/not configured and last rotation; never reveal the stored value.

Public-product onboarding requires broker third-party approval and separate user authorization. Personal grants cannot be reused as a multi-user login mechanism.

## 20. Interface implementation acceptance

Cover 320, 390, 768, 1024 and 1440 px widths; light/dark; keyboard-only navigation; 200% text/zoom; no color-only statuses; missing quotes; unavailable event coverage; unknown submit; manual broker position; revoked scope; empty account; multi-account switch; unsupported adjusted option; and quantity rounding. All visible trade actions share the server validation contract. Local estimates are always reconciled with server results before execution.

The prototype demonstrates navigation, local trade sizing/payoff, scenario controls, draft strategy editing, local paper order flow, pause state, inbox acknowledgment and simulated quote disconnection. It deliberately leaves broker connections and live actions unavailable.
