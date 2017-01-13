use Mix.Config

config :identity, Identity.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "identity_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
