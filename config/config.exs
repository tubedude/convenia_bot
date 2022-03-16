# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :convenia_bot,
  namespace: CB,
  # ecto_repos: [CB.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :convenia_bot, CBWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "8ItqXnILpFKyXTjFVRYEz2IW3l7jBQVFN1/7aqEL737wNjp+4LCbfWzhJyKAtbLA",
  render_errors: [view: CBWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: CB.PubSub],
  live_view: [signing_salt: "rS3ZGfZ+"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phoenix, :filter_parameters, ["secret_user", "secret_pass"]

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :convenia_bot, CB.Scheduler,
  timezone: "America/Sao_Paulo",
  jobs: [
    reset: [
      schedule: "0 23 * * *",
      task: {CB.Employees, :reset, []}
    ],
    check_for_bday: [
      schedule: "@daily",
      task: {CB.Employees, :check_for_bday, []}
    ],
    check_admissions: [
      schedule: "0 6 * * 1-5",
      task: {CB.Employees, :check_admissions, []}
    ]
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
