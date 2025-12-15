CREATE TABLE IF NOT EXISTS ops.pipeline_runs (
  run_id            BIGSERIAL PRIMARY KEY,
  run_type          TEXT NOT NULL CHECK (run_type IN ('SCHEDULED','MANUAL','BACKFILL')),
  run_start         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  run_end           TIMESTAMPTZ NULL,
  status            TEXT NOT NULL CHECK (status IN ('RUNNING','SUCCESS','FAILED')),
  triggered_by      TEXT NULL,   -- username or system
  notes             TEXT NULL
);

CREATE TABLE IF NOT EXISTS ops.task_runs (
  task_run_id       BIGSERIAL PRIMARY KEY,
  run_id            BIGINT NOT NULL REFERENCES ops.pipeline_runs(run_id),
  task_name         TEXT NOT NULL,
  status            TEXT NOT NULL CHECK (status IN ('RUNNING','SUCCESS','FAILED','SKIPPED')),
  started_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  finished_at       TIMESTAMPTZ NULL,
  rows_affected     BIGINT NULL,
  error_message     TEXT NULL
);

CREATE INDEX IF NOT EXISTS ix_task_runs_run_id ON ops.task_runs(run_id);
