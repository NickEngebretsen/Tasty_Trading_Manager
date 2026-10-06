# High-impact test matrix and release gates

No runtime broker or OpenAI integration has been executed for this design. These are required implementation tests. Prototype checks are reported in README separately.

| ID | Case | Required outcome | Stage |
|---|---|---|---|
| T01 | OAuth expiry while concurrent workers read | One refresh per credential set; requests resume without leaking secrets | Integration |
| T02 | Sandbox credentials selected with production URL | Environment mismatch blocks before routing | Integration |
| T03 | Wrong account or user in request | Access denied with no cross-account data | Foundation |
| T04 | Option symbol contains spaces or special characters | Broker-resolved exact symbol; correct URL encoding only in URL | Integration |
| T05 | Contract adjusted deliverable unsupported | Automated proposal cannot proceed; original metadata visible | Analytics |
| T06 | Vega/theta unit mismatch in provider | Unit validation fails instead of incorrect aggregation | Analytics |
| T07 | $380-risk contract with $100 budget | Quantity zero and clear indivisible-risk explanation | Risk |
| T08 | Credit/debit direction or action incorrect | Semantic validation and broker preflight reject | Risk |
| T09 | Two strategies reserve the same capacity concurrently | Serial/atomic evaluation; total capacity never double spent | Risk |
| T10 | Working entries plus existing positions exceed limit | New candidate blocked including pending reservations | Risk |
| T11 | Closing long protective leg leaves a short uncovered | Risk-increasing close detected; approval/capability required | Risk |
| T12 | Timeout after broker accepted order | UNKNOWN persists; reserve retained; no blind resubmit | Execution |
| T13 | Writer crashes before recording acknowledgment | Restart reconciles order history/fills/positions before resuming | Execution |
| T14 | Broker search temporarily reports no matching order | Keep ambiguity through visibility window; no empty-read proof | Execution |
| T15 | Same internal dispatch request replayed | Same durable command returned; no new local intent | Execution |
| T16 | Same idempotency key with different payload | Conflict with no dispatch | Execution |
| T17 | Cancel and fill cross in flight | Actual filled inventory recorded; cancel acknowledgment not assumed | Execution |
| T18 | Partial fills and duplicate execution events | Filled quantity deduplicated; manager starts for actual exposure | Execution |
| T19 | Terminal broker status arrives before fill records | Reconciliation remains open until execution completeness checked | Execution |
| T20 | Old writer request in flight during lease expiry | No concurrent replacement writer; handover reconciles first | Execution |
| T21 | Restore old database/outbox | Financial outbox does not auto-submit; reconcile broker first | Operations |
| T22 | Quote socket alive but a candidate quote is stale | Candidate blocked independently of transport health | Data |
| T23 | Quiet instrument has no new event | Distinguish quiet trading from disconnection; fresh snapshot policy | Data |
| T24 | Bid/ask crossed or suspect price spike | Quality rules prevent false stop/entry triggers | Data |
| T25 | Feed subscription capacity exceeded | Position/exit priorities preserved; research subscriptions shed | Data |
| T26 | Account stream disconnects but quotes continue | Account health degraded; new-risk policy uses fresh reconciliation | Data |
| T27 | Buffer/reconnect lacks a reliable sequence watermark | Stable resnapshot or explicit uncertainty; no invented atomic state | Portfolio |
| T28 | User trades directly in broker app | Position/order appears Unassigned and consumes risk capacity | Portfolio |
| T29 | Assignment changes option into stock holding | Holdings/cash/risk updated and relevant entry conflicts paused | Options |
| T30 | Short option around ex-dividend/low extrinsic | Assignment action flag with exact source/contract and funding check | Options |
| T31 | Expiry on early-close/holiday/AM settlement | Instrument calendar and verified cutoff determine actions | Options |
| T32 | Exercise/DNE API not verified | Manual broker action required or conservative close policy | Options |
| T33 | Broker margin changes after preflight | Fresh dispatch check blocks or rebuilds intent | Risk |
| T34 | Event calendar unknown/revised | Unknown blocks default entry; revisions retained | Data |
| T35 | Cash proceeds unsettled | No implied settled cash from buying-power number | Portfolio |
| T36 | Roll of losing option | Old realized P/L retained; new position risk/fees separate | Portfolio |
| T37 | Corporate action restates cost/contract | Effective revisions preserved; replay uses then-known metadata | Portfolio |
| T38 | Same trade in paper versus live journal | Different ledgers and performance cohorts | Portfolio |
| T39 | LLM cites nonexistent evidence or stale price | Claim/proposal rejected or corrected by trusted tools | AI |
| T40 | News contains instructions to trade/change limits | Untrusted evidence has no command authority | AI |
| T41 | LLM output is valid JSON but impossible economics | Semantic/quant checks block | AI |
| T42 | AI service fails or hits cost cap | Existing deterministic manager continues; dependent entries stop | AI |
| T43 | New model/prompt revision | Versioned shadow evaluation; no inherited live authority | AI |
| T44 | Historical model already knows future outcome | Leakage risk documented; prospective evaluation required | Research |
| T45 | Today's constituents/chain used in past test | Point-in-time checks fail | Research |
| T46 | Midpoint-only backtest looks profitable | Spread/latency/nonfill/cost stress reported before promotion | Research |
| T47 | Independent legs used as atomic combo execution | Unsupported assumption disclosed; conservative replay comparison | Research |
| T48 | Mass parameter search selects one winner | Full experiment count/holdout and robustness evidence retained | Research |
| T49 | Changed strategy parameters while live | New draft artifact; existing managers remain on approved version | Automation |
| T50 | Pause entries | Entries stopped; protective/management actions preserved | Automation |
| T51 | Flatten selected inventory removes hedge first | Ordered risk-reviewed plan and residual exposure displayed | Automation |
| T52 | Critical notification undelivered | Delivery incident persists; configured escalation and entry policy | Alerts |
| T53 | User acknowledges an unresolved order incident | Acknowledged only; financial incident remains open | Alerts |
| T54 | Mobile approval opens after price/TTL change | Revalidate; stale authorization cannot dispatch | UI |
| T55 | Switch account/mode with ticket open | Approval invalidated; context visibly changed | UI |
| T56 | Narrow display/keyboard/zoom/dark mode | Labels, units, status and primary actions remain usable | UI |

## Gates

**Read-only release:** T01–T04, T22–T28, basic ledger matching, no accessible write credential and user-visible connection ages. **Paper/analytics:** payoff/unit fixtures, T05–T11, T34–T38, realistic fill assumptions and clear simulation labels. **Supervised live:** T12–T21, T29–T33, verified management paths, broker capability evidence and explicit account/payload approval. **Bounded live:** T39–T55, unchanged immutable artifacts, prospective strategy evidence, independent outage alert and rehearsed recovery. **Advanced/multi-user:** tenant isolation, broker verification, license/entitlement checks and feature-specific operational tests.

A failed core gate blocks the affected capability; it does not need to block unrelated read-only tools. Operational gates and return/edge evidence are evaluated separately.
