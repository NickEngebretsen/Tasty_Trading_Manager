# Primary-source research register

Checked October 6, 2026. Sources establish current documented capabilities or design patterns; account entitlements and exact executable contracts still require integration verification. Dates, access, prices, regulatory implementation and API schemas can change. All architecture and proposed policies in this pack are our design recommendations.

| ID | Primary source | Use in the design |
|---|---|---|
| S01 | [tastytrade OAuth](https://developer.tastytrade.com/docs/authentication/oauth2/) | Current token flow, environment separation and personal versus third-party apps |
| S02 | [Stream market data](https://developer.tastytrade.com/docs/guides/stream-market-data/) | DXLink, quote tokens, event fields and broker-provided stream symbols |
| S03 | [Stream account updates](https://developer.tastytrade.com/docs/guides/stream-account-updates/) | Independent account notifications and authentication |
| S04 | [Rate limits and backoff](https://developer.tastytrade.com/docs/guides/rate-limits-and-backoff/) | REST backoff versus documented stream caps |
| S05 | [Sandbox](https://developer.tastytrade.com/docs/sandbox/) | Synthetic fills, unavailable market-data routes and reset behavior |
| S06 | [Options backtesting](https://developer.tastytrade.com/docs/guides/backtesting/) | Separate backtester host, coverage discovery and result inspection |
| S07 | [Idempotency and retries](https://developer.tastytrade.com/docs/guides/idempotency-and-retries/) | Correlation handles do not guarantee broker-side deduplication |
| S08 | [Orders reference](https://developer.tastytrade.com/reference/orders/) and [order types](https://developer.tastytrade.com/docs/concepts/orders-and-order-types/) | Submit, preflight, cancel, edit, replace and complex orders |
| S09 | [Order lifecycle](https://developer.tastytrade.com/docs/concepts/order-lifecycle/) | Raw broker states and reconciliation around fills |
| S10 | [tastytrade MCP server](https://developer.tastytrade.com/docs/sdks-and-tools/mcp-server/) | Optional self-hosted integration and read-only/environment settings |
| S11 | [TradingView features](https://www.tradingview.com/features/) | Linked charts, market exploration and alert patterns |
| S12 | [OptionStrat features](https://optionstrat.com/features) | Payoff exploration and candidate optimization; direct fetch was restricted, official search content inspected |
| S13 | [Option Alpha backtesting](https://docs.optionalpha.com/tools/backtesting) and [automation testing](https://docs.optionalpha.com/technical-documentation/troubleshooting/testing-automations) | Research-to-automation continuity and decision logs |
| S14 | [QuantConnect tastytrade integration](https://www.quantconnect.com/docs/v2/cloud-platform/live-trading/brokerages/tastytrade) and [backtesting](https://www.quantconnect.com/docs/v2/cloud-platform/backtesting/getting-started) | Evaluate existing brokerage/research engine and paper model |
| S15 | [Massive historical option quotes](https://www.massive.com/docs/rest/options/trades-quotes/quotes) | Historical bid/ask data candidate; verify selected plan rights and coverage |
| S16 | [Databento options NBBO example](https://databento.com/docs/examples/options/nbbo-resampling) and [dataset details](https://databento.com/docs/venues-and-datasets) | OPRA data and point-in-time symbol/coverage considerations |
| S17 | [SEC EDGAR APIs](https://www.sec.gov/search-filings/edgar-application-programming-interfaces) | Filing submissions and XBRL fundamentals |
| S18 | [FRED/ALFRED API](https://fred.stlouisfed.org/docs/api/fred/) | Economic series, releases and observation vintages |
| S19 | [FINRA options](https://www.finra.org/investors/investing/investment-products/options) | Exercise, assignment and option-specific risks |
| S20 | [OpenAI function calling](https://developers.openai.com/api/docs/guides/function-calling) | Typed controlled tools and strict schemas |
| S21 | [OpenAI structured outputs](https://developers.openai.com/api/docs/guides/structured-outputs) | Proposal output contract; semantic correctness still external |
| S22 | [OpenAI data controls](https://developers.openai.com/api/docs/guides/your-data) | Feature-specific retention and data-minimizing design |
| S23 | [Interactive Brokers Risk Navigator](https://www.interactivebrokers.com/en/trading/risk-navigator.php) | Hypothetical portfolios and scenario drill-down |
| S24 | [FINRA intraday-margin transition](https://syndication.finra.org/content/understanding-new-intraday-margin-requirements) | Avoid a hard-coded universal PDT regime during broker transition |
| S25 | [IRS Schedule D instructions](https://www.irs.gov/instructions/i1040sd) | Wash-sale review and recordkeeping requirements |
| S26 | [SEC settlement-cycle risk alert](https://www.sec.gov/compliance/risk-alerts/shortening-securities-transaction-settlement-cycle) | General T+1 settlement framework; account/product availability still verified |
| S27 | [TradeZella features](https://www.tradezella.com/features) | Journal, setup attribution and replay patterns |
| S28 | [Balances and positions](https://developer.tastytrade.com/reference/balances-and-positions/) and [transactions](https://developer.tastytrade.com/reference/transactions/) | Portfolio source-of-truth endpoints |
| S29 | [Instruments and symbology](https://developer.tastytrade.com/docs/concepts/instruments-and-symbology/) | Broker symbols, metadata and stream identifiers |
| S30 | [Market sessions](https://developer.tastytrade.com/reference/market-sessions/) and [margin/risk](https://developer.tastytrade.com/docs/concepts/margin-and-risk/) | Session calendars, restrictions and broker margin hypotheses |

## Evidence versus assumptions

Verified documentation: tastytrade supports the referenced families of reads, order management and streams; certification is not realistic paper execution; the documented backtester is separate; current official OpenAI docs support structured tool/output contracts. Proposed design: our architecture, risk tiers, schedules, sizing policies, data quality rules, UI, backlog, service targets and budgets. To verify at implementation: account-specific approvals, exact request schemas, runtime delivery/order guarantees, historical coverage, vendor rights, exercise/DNE operations and the broker's current day-trading regime.

## Important contradictions and limitations retained

Some reference banners mention request use of `ext-client-order-id` while the broker's retry guide identifies it as read-only and points to `external-identifier`. The reference operation index can also differ between older `/open-api-spec/` pages and current `/reference/` pages. Contract tests against the current schema/environment decide enabled capabilities; the application does not silently choose whichever prose looks convenient.

OptionStrat's direct pages returned a fetch restriction; its official indexed feature descriptions supported the limited design-pattern comparison. No claims about proprietary implementation, broker compatibility or purchase pricing are made from that limited access.
