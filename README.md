# Tasty Trading Manager

A personal stock and options trading workbench designed around tastytrade and an OpenAI assistant.

This repository currently contains the original **Trading System Design Pack, revision 1**, and an authentication walkthrough. Application source code from the local development project has not been imported yet. The pack describes a future implementation; it does not establish a working account connection or authorize live trading.

## Start here

- [Design pack guide](docs/design-pack/00_README.md)
- [Complete blueprint](docs/design-pack/01_Trading_System_Blueprint.md)
- [PDF blueprint](docs/design-pack/Trading_System_Blueprint.pdf)
- [Screen prototype](docs/design-pack/04_Trade_Workbench_Screens.html) — download and open locally; uses synthetic data
- [Authentication: components, request flow, credentials and gaps](docs/AUTHENTICATION.md)
- [Implementation handoff](docs/design-pack/11_Implementation_Handoff.md)
- [Implementation backlog](docs/design-pack/08_Implementation_Backlog.csv)

All 14 files from the original ZIP are preserved under `docs/design-pack/`. Its artifact manifest retains the original checksums. The ZIP's PDF is preserved as supplied, without substituting another PDF revision.

## Current implementation status

| Asset | Status |
|---|---|
| HTML screen prototype | Local JavaScript interactions with synthetic data |
| SQL schema, proposal schema, strategy example | Starter contracts |
| API endpoints, broker gateway, OAuth TokenManager | Specified; not implemented in this import |
| App login, session management, secret storage | Required by the design; not implemented in this import |
| Broker, OpenAI, notifications and live execution | No integrations configured by these files |

## Importing the existing local application

If the local code has no Git history that needs preserving, use a fresh checkout of this repository, create an import branch, and copy the application source into it while retaining this documentation. Inspect the staged diff before committing. Do not copy `.git`, `.env`, token caches, private keys, local databases, dependency folders or build output from the old folder.

If the local application already has Git history, preserve that history and reconcile the two repositories deliberately. Do not force-push over this initial documentation import. A source ZIP uploaded for review can be imported without exposing local credentials, but a ZIP alone will not preserve its Git history.

The included `.gitignore` excludes common local secret files and generated artifacts. Ignore rules do not remove secrets already tracked by Git.

## First development milestone

Implement the read-only account connection described in the handoff: TokenManager, account discovery, balances/positions/orders, account stream, normalized snapshots, reconciliation, and portfolio/operations UI. Authentication and account authorization must be enforced server-side before exposing real account data.
