use Mix.Config

# Configure your database
# config :convenia_bot, CB.Repo,
#   username: "postgres",
#   password: "postgres",
#   database: "convenia_bot_test",
#   hostname: "localhost",
#   pool: Ecto.Adapters.SQL.Sandbox

config :convenia_bot, :convenia_token, "x"
config :convenia_bot, :secret_user, "1"
config :convenia_bot, :secret_pass, "a"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :convenia_bot, CBWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
