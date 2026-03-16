-- Migration 002: Add per-user auth
-- Run this in Supabase SQL Editor AFTER migration 001

-- ── Drop existing open policies ───────────────────────────────────────────────
DROP POLICY IF EXISTS "anon_all_accounts"     ON accounts;
DROP POLICY IF EXISTS "anon_all_transactions" ON transactions;

-- ── Add user_id columns ───────────────────────────────────────────────────────
ALTER TABLE accounts     ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE;

-- ── Clear any existing data (it has no user_id and can't be claimed) ──────────
TRUNCATE TABLE transactions;
TRUNCATE TABLE accounts;

-- ── Make user_id required now that the table is empty ────────────────────────
ALTER TABLE accounts     ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE transactions ALTER COLUMN user_id SET NOT NULL;

-- ── New RLS policies: each user sees only their own rows ─────────────────────
CREATE POLICY "users_own_accounts"
    ON accounts FOR ALL
    USING  (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_own_transactions"
    ON transactions FOR ALL
    USING  (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);
