-- Every check writes a row here (your audit trail for "why trust changed")
CREATE TABLE IF NOT EXISTS dq.check_results (
  check_id          BIGSERIAL PRIMARY KEY,
  run_id            BIGINT NULL REFERENCES ops.pipeline_runs(run_id),
  batch_date        DATE NOT NULL,
  check_name        TEXT NOT NULL,
  severity          TEXT NOT NULL CHECK (severity IN ('INFO','WARN','CRITICAL')),
  passed            BOOLEAN NOT NULL,
  observed_value    TEXT NULL,
  expected_value    TEXT NULL,
  details           TEXT NULL,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Schema drift events
CREATE TABLE IF NOT EXISTS dq.schema_drift_log (
  drift_id          BIGSERIAL PRIMARY KEY,
  batch_date        DATE NOT NULL,
  drift_type        TEXT NOT NULL CHECK (drift_type IN ('ADDITIVE','BREAKING','TYPE_CHANGE','UNKNOWN')),
  column_name       TEXT NULL,
  old_type          TEXT NULL,
  new_type          TEXT NULL,
  details           TEXT NULL,
  detected_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Late data tracking
CREATE TABLE IF NOT EXISTS dq.late_data_log (
  late_id           BIGSERIAL PRIMARY KEY,
  batch_date        DATE NOT NULL,
  late_event_count  BIGINT NOT NULL,
  max_lateness_hrs  NUMERIC NULL,
  details           TEXT NULL,
  detected_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Metric trust status (the product)
CREATE TABLE IF NOT EXISTS dq.metric_trust_status (
  trust_id          BIGSERIAL PRIMARY KEY,
  run_id            BIGINT NULL REFERENCES ops.pipeline_runs(run_id),
  metric_name       TEXT NOT NULL,
  metric_date       DATE NOT NULL,
  status            TEXT NOT NULL CHECK (status IN ('GREEN','YELLOW','RED')),
  reason            TEXT NOT NULL,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS ix_check_results_date ON dq.check_results(batch_date);
CREATE INDEX IF NOT EXISTS ix_trust_metric_date ON dq.metric_trust_status(metric_date, metric_name);
