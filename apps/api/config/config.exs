# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :geosnap_api,
  namespace: Geosnap.Api

# Configures the endpoint
config :geosnap_api, Geosnap.Api.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Zc8SO0vWemcxtGFYlThW87tD4IHeHwLLxmvNkqqerQ/qt+uruAChCodPpmKUrifp",
  render_errors: [view: Geosnap.Api.ErrorView, accepts: ~w(json)],
  pubsub: [name: Geosnap.Api.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
