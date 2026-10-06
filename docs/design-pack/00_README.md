# Trade Workbench design pack

Revision 1 — October 6, 2026

A detailed plan for a personal automated stock and options trading system using OpenAI and tastytrade, with interface designs, implementation contracts, dependencies and release criteria. This pack is a design and development handoff. It does not connect to an account, call a model, send notifications or route live orders.

## Read and explore

Start with `Trading_System_Blueprint.pdf` for the complete narrative and screen specifications. Use its bookmarks to navigate the 53-page document. Open `04_Trade_Workbench_Screens.html` in a modern browser for the self-contained 17-view interface prototype. It requires no account, API key, installation or network connection.

The prototype contains synthetic balances, prices, positions and performance. It demonstrates a trade builder, local paper-order review, budget checks, a portfolio stress calculator, order cancellation, strategy pause, incident acknowledgment, a journal and outage/recovery controls. These local interactions illustrate the intended workflow. They are not a broker sandbox or a realistic paper-trading engine. The sample lab curve is not a backtest result.

## Files

| File | Purpose |
|---|---|
| `01_Trading_System_Blueprint.md` | Product scope; researched platform ideas; broker capabilities; architecture; data; quant; AI; strategies; execution; risk; accounting; communication; operations; roadmap and costs |
| `02_Screen_and_Interaction_Specifications.md` | Screen layouts, fields, workflows, system states, mobile behavior and acceptance criteria |
| `03_API_and_Event_Contracts.md` | Proposed application endpoints, domain identifiers, errors, events and execution pseudocode |
| `04_Trade_Workbench_Screens.html` | Complete standalone interface prototype using only local synthetic data |
| `05_database.sql` | Starter PostgreSQL data model; production migrations, role grants and ledger invariants still require implementation |
| `06_trade_proposal.schema.json` | Strict draft-proposal structure; semantic validation and account risk authorization remain application responsibilities |
| `07_strategy.example.yaml` | Illustrative versioned paper/shadow strategy recipe; no demonstrated trading edge |
| `08_Implementation_Backlog.csv` | 116 tasks with stages, dependencies and required acceptance evidence |
| `09_Test_Matrix_and_Release_Gates.md` | 56 proposed high-impact test cases and progressive release gates |
| `10_Source_Register.md` | 30 official source entries, their uses and verification boundaries |
| `11_Implementation_Handoff.md` | Repository organization, first vertical slice and concrete implementation rules |
| `12_Artifact_Manifest.json` | File sizes and SHA-256 checksums for this revision |
| `Trading_System_Blueprint.pdf` | Readable compilation of the blueprint, screens, contracts, test matrix, sources and handoff |

## What was checked

- The backlog has 116 unique task IDs, valid dependencies, no dependency cycle and no prerequisite assigned to a later stage.
- The proposal JSON parses; all three object definitions require every declared property and reject undeclared properties. This checks strict structure, not model performance or supported production API behavior.
- The strategy YAML parses. Its evaluator is not implemented.
- The prototype has 17 views, 80 unique element IDs and no external script or stylesheet dependency. Its JavaScript passes a syntax check.
- Independent Decimal calculations match the worked debit-spread cost/risk/payoff, rejected credit-spread sizing, example account value, open P/L, approximate stress result and annual subscription-cost drag.
- The PDF has 53 pages and 132 navigation bookmarks. Extracted text contains no replacement glyphs or text outside page bounds. Representative pages were visually inspected.
- The archive passes ZIP integrity verification, and the manifest records reproducible file checksums.

Full browser rendering and interaction testing were unavailable in the preparation environment. Responsive layout, accessibility and interaction behavior still need a real browser review. Broker integration, SQL deployment, backend fault cases and the 56 proposed tests have not been executed. Their required evidence is defined in the pack.

## Implementation priority

Build the read-only account-to-portfolio-to-reconciliation slice first. Add exact instrument and quant conventions, global risk reservations, local paper/replay and uncertainty recovery before broker execution. Evaluate the native tastytrade backtester and QuantConnect/LEAN before committing to a custom research engine. Promote one supported strategy and one broker order path at a time.

The OpenAI assistant receives scoped research/read/draft tools. The server owns account identity, authorization, sizing, numerical risk and order submission. Strategy risk budgets share an account-wide ceiling. Missing data and unresolved submissions remain visible incidents rather than optimistic assumptions.

The budgets, fee examples, stale-data thresholds, timelines and strategies in this pack are proposed engineering assumptions. They are not user-selected limits, purchased subscriptions, activated automation or evidence of future returns. Confirm current schemas, permissions, entitlements and the account's trading-rule regime at implementation kickoff.
