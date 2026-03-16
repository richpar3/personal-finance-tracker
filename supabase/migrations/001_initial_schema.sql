-- Personal Finance Tracker – Initial Schema

-- ── Accounts ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS accounts (
    id               uuid            PRIMARY KEY,
    name             text            NOT NULL,
    type             text            NOT NULL,
    balance          double precision NOT NULL DEFAULT 0,
    currency         text            NOT NULL DEFAULT 'USD',
    last_four_digits text,
    color            text            NOT NULL DEFAULT '#4A90D9',
    notes            text            NOT NULL DEFAULT '',
    created_at       timestamptz     NOT NULL DEFAULT now()
);

-- ── Transactions ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS transactions (
    id           uuid             PRIMARY KEY,
    date         timestamptz      NOT NULL,
    category     text             NOT NULL,
    amount       double precision NOT NULL,
    account_id   uuid             NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    account_name text             NOT NULL,
    description  text             NOT NULL DEFAULT '',
    type         text             NOT NULL,
    notes        text             NOT NULL DEFAULT '',
    is_recurring boolean          NOT NULL DEFAULT false,
    tags         text[]           NOT NULL DEFAULT '{}',
    created_at   timestamptz      NOT NULL DEFAULT now()
);

-- ── Indexes ──────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_transactions_account_id ON transactions(account_id);
CREATE INDEX IF NOT EXISTS idx_transactions_date       ON transactions(date DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_type       ON transactions(type);

-- ── Row Level Security ────────────────────────────────────────────────────────
-- Single-user app using anon key – allow full access without auth
ALTER TABLE accounts     ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "anon_all_accounts"     ON accounts     FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "anon_all_transactions" ON transactions FOR ALL USING (true) WITH CHECK (true);
