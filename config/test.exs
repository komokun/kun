use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :kun, KunWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :kun, Kun.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "kun_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

  config :argon2_elixir,
  t_cost: 2,
  m_cost: 12

config :kun, Kun.UserManager.Guardian,
  issuer: "kun",
  secret_key: "TWXoGEWDNRdDgDsYsbIavTU2CqHefT/iDfjnpW5d9yFFcjdZCjlPL4HZqKH+7xDp"
