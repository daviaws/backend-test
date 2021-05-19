# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :platform,
  ecto_repos: [Platform.Repo]

# Configures the endpoint
config :platform, PlatformWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "TbrATtk/8pNf+R8dfZvvneV/dFv6L4JZJRyAZlYrtVcl6wZ7WSnTqpVsZX4Klpi1",
  render_errors: [view: PlatformWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Platform.PubSub,
  live_view: [signing_salt: "ENKthbzk"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
