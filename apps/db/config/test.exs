use Mix.Config

config :geosnap_db, Geosnap.Db.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox,
  extensions: [{Geo.PostGIS.Extension, library: Geo}],
  database: "geosnap_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
