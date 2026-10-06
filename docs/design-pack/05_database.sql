-- PostgreSQL starter migration. Application commands and production permission
-- migrations must enforce transitions, append-only audit, tenant scope and ledger
-- balancing. This is a reviewed design skeleton, not a deployed trading database.
BEGIN;

CREATE TABLE accounts (
    id uuid PRIMARY KEY,
    owner_id uuid NOT NULL,
    environment text NOT NULL CHECK (environment IN ('readonly','sandbox','paper','shadow','live')),
    broker text NOT NULL,
    broker_account_reference text NOT NULL,
    alias text NOT NULL,
    currency char(3) NOT NULL,
    credential_vault_reference text,
    revision bigint NOT NULL DEFAULT 0 CHECK (revision >= 0),
    entries_paused boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL,
    UNIQUE (broker, environment, broker_account_reference)
);

CREATE TABLE instruments (
    id uuid PRIMARY KEY,
    kind text NOT NULL CHECK (kind IN ('equity','equity_option','index_option','index')),
    underlying_id uuid REFERENCES instruments(id),
    currency char(3) NOT NULL,
    display_symbol text NOT NULL,
    definition_revision bigint NOT NULL,
    broker_symbol text NOT NULL,
    streamer_symbol text,
    expiration_at timestamptz,
    last_trade_at timestamptz,
    option_right text CHECK (option_right IN ('call','put')),
    strike numeric(24,8),
    premium_multiplier numeric(20,8) NOT NULL CHECK (premium_multiplier > 0),
    quantity_step numeric(20,8) NOT NULL CHECK (quantity_step > 0),
    adjusted boolean NOT NULL DEFAULT false,
    deliverables jsonb NOT NULL,
    exercise_style text,
    settlement_style text,
    definition_hash char(64) NOT NULL,
    raw_definition jsonb NOT NULL
);

CREATE TABLE strategy_versions (
    id uuid PRIMARY KEY,
    strategy_id uuid NOT NULL,
    version integer NOT NULL CHECK (version > 0),
    artifact_hash char(64) NOT NULL UNIQUE,
    definition jsonb NOT NULL,
    engine_version text NOT NULL,
    created_at timestamptz NOT NULL,
    UNIQUE(strategy_id, version)
);

CREATE TABLE risk_policy_versions (
    id uuid PRIMARY KEY,
    policy_id uuid NOT NULL,
    version integer NOT NULL CHECK (version > 0),
    artifact_hash char(64) NOT NULL UNIQUE,
    definition jsonb NOT NULL,
    created_at timestamptz NOT NULL,
    UNIQUE(policy_id, version)
);

CREATE TABLE authorizations (
    id uuid PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES accounts(id),
    user_id uuid NOT NULL,
    strategy_version_id uuid REFERENCES strategy_versions(id),
    risk_policy_version_id uuid NOT NULL REFERENCES risk_policy_versions(id),
    payload_hash char(64),
    authority_envelope jsonb NOT NULL,
    issued_at timestamptz NOT NULL,
    expires_at timestamptz NOT NULL,
    revoked_at timestamptz,
    CHECK(expires_at > issued_at)
);

CREATE TABLE snapshots (
    id uuid PRIMARY KEY,
    account_id uuid REFERENCES accounts(id),
    kind text NOT NULL CHECK (kind IN ('account','market','risk','decision')),
    revision bigint NOT NULL CHECK(revision >= 0),
    as_of timestamptz NOT NULL,
    ingested_at timestamptz NOT NULL,
    manifest_hash char(64) NOT NULL,
    payload jsonb NOT NULL,
    quality jsonb NOT NULL
);
CREATE INDEX snapshots_account_time ON snapshots(account_id, kind, as_of DESC);

CREATE TABLE trade_intents (
    id uuid PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES accounts(id),
    strategy_version_id uuid REFERENCES strategy_versions(id),
    risk_policy_version_id uuid NOT NULL REFERENCES risk_policy_versions(id),
    authorization_id uuid REFERENCES authorizations(id),
    account_snapshot_id uuid NOT NULL REFERENCES snapshots(id),
    market_snapshot_id uuid NOT NULL REFERENCES snapshots(id),
    decision_key text NOT NULL,
    external_identifier uuid NOT NULL UNIQUE,
    payload_hash char(64) NOT NULL,
    immutable_payload jsonb NOT NULL,
    execution_policy jsonb NOT NULL,
    state text NOT NULL CHECK(state IN ('proposed','blocked','validated','authorized','reserved','prepared','submitting','unknown','working','partial','cancel_pending','filled','cancelled','rejected','managed','closed','reconciled','review')),
    revision bigint NOT NULL DEFAULT 0 CHECK(revision >= 0),
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL,
    UNIQUE(account_id, decision_key)
);
CREATE INDEX intents_account_state ON trade_intents(account_id, state, updated_at);

CREATE TABLE risk_reservations (
    id uuid PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES accounts(id),
    intent_id uuid NOT NULL UNIQUE REFERENCES trade_intents(id),
    currency char(3) NOT NULL,
    economic_risk numeric(24,8) NOT NULL CHECK(economic_risk >= 0),
    buying_power numeric(24,8) NOT NULL CHECK(buying_power >= 0),
    exposure_dimensions jsonb NOT NULL,
    state text NOT NULL CHECK(state IN ('reserved','unknown','partly_exposed','exposed','released')),
    revision bigint NOT NULL DEFAULT 0,
    updated_at timestamptz NOT NULL
);
-- TTL alone must never release a reservation on an unknown financial outcome.

CREATE TABLE broker_orders (
    id uuid PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES accounts(id),
    intent_id uuid REFERENCES trade_intents(id),
    broker_order_id text NOT NULL,
    external_identifier text,
    raw_status text NOT NULL,
    raw_object jsonb NOT NULL,
    observed_at timestamptz NOT NULL,
    reconciliation_state text NOT NULL,
    UNIQUE(account_id, broker_order_id)
);

CREATE TABLE fills (
    id uuid PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES accounts(id),
    broker_order_id uuid NOT NULL REFERENCES broker_orders(id),
    instrument_id uuid NOT NULL REFERENCES instruments(id),
    broker_execution_id text NOT NULL,
    leg_index integer NOT NULL CHECK(leg_index >= 0),
    quantity numeric(24,8) NOT NULL CHECK(quantity > 0),
    price numeric(24,8) NOT NULL CHECK(price >= 0),
    direction text NOT NULL CHECK(direction IN ('buy','sell')),
    executed_at timestamptz NOT NULL,
    received_at timestamptz NOT NULL,
    raw_execution jsonb NOT NULL,
    UNIQUE(account_id, broker_execution_id, instrument_id, leg_index)
);
-- Confirm broker execution-ID scope and correction rules in contract tests.

CREATE TABLE ledger_batches (
    id uuid PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES accounts(id),
    source_event_id text NOT NULL,
    source text NOT NULL,
    happened_at timestamptz NOT NULL,
    correction_of uuid REFERENCES ledger_batches(id),
    evidence jsonb NOT NULL,
    UNIQUE(account_id, source, source_event_id)
);
CREATE TABLE ledger_entries (
    id uuid PRIMARY KEY,
    batch_id uuid NOT NULL REFERENCES ledger_batches(id),
    ledger_account text NOT NULL,
    currency char(3) NOT NULL,
    debit numeric(24,8) NOT NULL DEFAULT 0 CHECK(debit >= 0),
    credit numeric(24,8) NOT NULL DEFAULT 0 CHECK(credit >= 0),
    instrument_id uuid REFERENCES instruments(id),
    quantity numeric(24,8),
    CHECK ((debit = 0) OR (credit = 0))
);
-- Production ingestion validates sum(debit)=sum(credit) per currency/batch
-- in the same transaction, with deferred constraint triggers as a safeguard.

CREATE TABLE domain_events (
    id uuid PRIMARY KEY,
    account_id uuid REFERENCES accounts(id),
    environment text NOT NULL,
    aggregate_id uuid NOT NULL,
    aggregate_revision bigint NOT NULL CHECK(aggregate_revision >= 0),
    type text NOT NULL,
    schema_version integer NOT NULL CHECK(schema_version > 0),
    occurred_at timestamptz NOT NULL,
    received_at timestamptz NOT NULL,
    correlation_id uuid NOT NULL,
    causation_id uuid,
    payload jsonb NOT NULL,
    UNIQUE(aggregate_id, aggregate_revision)
);
CREATE INDEX events_account_time ON domain_events(account_id, received_at);

CREATE TABLE outbox (
    id uuid PRIMARY KEY,
    event_id uuid NOT NULL REFERENCES domain_events(id),
    destination text NOT NULL,
    dedupe_key text NOT NULL,
    state text NOT NULL CHECK(state IN ('pending','claimed','delivered','failed')),
    attempts integer NOT NULL DEFAULT 0 CHECK(attempts >= 0),
    next_attempt_at timestamptz NOT NULL,
    lease_until timestamptz,
    UNIQUE(destination, dedupe_key)
);
-- Delivery retries do not authorize broker resubmission.

CREATE TABLE account_writer_leases (
    account_id uuid PRIMARY KEY REFERENCES accounts(id),
    writer_id uuid NOT NULL,
    fencing_token bigint NOT NULL CHECK(fencing_token > 0),
    lease_until timestamptz NOT NULL,
    handover_state text NOT NULL CHECK(handover_state IN ('active','draining','reconcile_required','stopped'))
);

CREATE TABLE incidents (
    id uuid PRIMARY KEY,
    account_id uuid REFERENCES accounts(id),
    incident_key text NOT NULL,
    severity text NOT NULL CHECK(severity IN ('info','warning','critical')),
    state text NOT NULL CHECK(state IN ('open','acknowledged','acting','resolved')),
    object_id uuid,
    opened_at timestamptz NOT NULL,
    acknowledged_at timestamptz,
    resolved_at timestamptz,
    deadline_at timestamptz,
    evidence jsonb NOT NULL
);
CREATE UNIQUE INDEX active_incident_key ON incidents(account_id, incident_key)
    WHERE state <> 'resolved';

CREATE TABLE experiments (
    id uuid PRIMARY KEY,
    strategy_version_id uuid NOT NULL REFERENCES strategy_versions(id),
    engine text NOT NULL,
    engine_version text NOT NULL,
    manifest_hash char(64) NOT NULL,
    dataset_manifest jsonb NOT NULL,
    assumptions jsonb NOT NULL,
    state text NOT NULL,
    artifact_reference text,
    created_at timestamptz NOT NULL
);

COMMIT;
