import Config

# NOTE: Runtime configuration (ports, URLs, credentials, database path) is in config/runtime.exs
# This file only contains compile-time configuration

config :exqlite,
  force_build: true,
  default_chunk_size: 100

# Configure Ecto repos (database path is in runtime.exs)-------------------------
config :job_svc,
  ecto_repos: [JobService.Repo],
  adapter: Ecto.Adapters.SQLite3,
  default_transaction_mode: :immediate,
  show_sensitive_data_on_connection_error: true,
  pool_size: 5

# Configure Oban (repo connection is in runtime.exs)---------------------------------
config :job_svc, Oban,
  repo: JobService.Repo,
  engine: Oban.Engines.Lite,
  log: :debug,
  queues: [
    default: 10,
    emails: 10,
    images: System.schedulers_online()
  ],
  poll_interval: 100,
  shutdown_grace_period: 30_000,
  plugins: [
    # Clean old jobs
    # {Oban.Plugins.Pruner, max_age: 3600},
    # Stage jobs faster
    # {Oban.Plugins.Stager, interval: 1000},
    # Cron plugin for scheduled jobs
    {Oban.Plugins.Cron,
     crontab: [
       # Cleanup old images every 15 minutes (files older than 1 hour)
       {"*/15 * * * *", StorageCleanupWorker}
     ]}
  ]

# PromEx configuration for Prometheus metrics---------------------------
config :job_svc, JobService.PromEx,
  disabled: false,
  manual_metrics_start_delay: :no_delay,
  drop_metrics_groups: [],
  grafana: :disabled,
  metrics_server: :disabled

# OpenTelemetry -------------------------------------------------------
config :opentelemetry,
  span_processor: :batch,
  traces_exporter: :otlp,
  resource: %{service: "job_svc"}

config :opentelemetry_ecto, :tracer, repos: [JobService.Repo]

# Add service name to all logs
config :logger, :default_formatter, metadata: [:service]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
