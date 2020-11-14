# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :x2048,
  ecto_repos: [X2048.Repo]

# Configures the endpoint
config :x2048, X2048Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "rOF8yLuil+bZlX1M/YU6+pCQ3wjL8PlGzIBKEqNRsbqBhxCLI+CVHk95YkyXE30+",
  render_errors: [view: X2048Web.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: X2048.PubSub,
  live_view: [signing_salt: "D9wls5wc"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
