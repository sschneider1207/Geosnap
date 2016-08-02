use Mix.Config

config :geosnap_db, Geosnap.Db.Repo,
  adapter: Ecto.Adapters.Postgres,
  extensions: [{Geo.PostGIS.Extension, library: Geo}],
  database: "geosnap_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
