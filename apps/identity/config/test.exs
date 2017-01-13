use Mix.Config

config :identity, Identity.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox,
  database: "identity_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
