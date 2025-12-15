-- RAW landing table: append-only, immutable
CREATE TABLE IF NOT EXISTS raw.events (
  event_time        TEXT,              -- keep raw string (parse in clean layer)
  event_type        TEXT,
  product_id        BIGINT,
  category_code     TEXT,
  brand            TEXT,
  price            NUMERIC,
  user_id           BIGINT,
  user_session      TEXT,

  -- operational fields
  source_file       TEXT NOT NULL,
  batch_date        DATE NOT NULL,
  ingested_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Track what batches/files were processed (state + idempotency)
CREATE TABLE IF NOT EXISTS raw.load_audit (
  audit_id          BIGSERIAL PRIMARY KEY,
  batch_date        DATE NOT NULL,
  source_file       TEXT NOT NULL,
  file_checksum     TEXT NULL,               -- optional but recommended
  row_count         BIGINT NOT NULL,
  status            TEXT NOT NULL CHECK (status IN ('STARTED','SUCCESS','FAILED','SKIPPED')),
  error_message     TEXT NULL,
  started_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  finished_at       TIMESTAMPTZ NULL
);

-- Prevent re-processing the same file for the same day
CREATE UNIQUE INDEX IF NOT EXISTS uq_load_audit_batch_file
ON raw.load_audit(batch_date, source_file);

-- Helpful indexes for downstream checks
CREATE INDEX IF NOT EXISTS ix_raw_events_batch_date ON raw.events(batch_date);
CREATE INDEX IF NOT EXISTS ix_raw_events_user_id ON raw.events(user_id);
