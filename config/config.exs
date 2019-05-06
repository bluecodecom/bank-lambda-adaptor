# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :bluecode_connector,
  ecto_repos: [BluecodeConnector.Repo]

# Configures the endpoint
config :bluecode_connector, BluecodeConnectorWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "YTE5FcN25IkGtINlf5Sgs0vBoHRddOmQAFNtTUgKT+eTR6HyzRMttMf6uOr4qjnE",
  render_errors: [view: BluecodeConnectorWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: BluecodeConnector.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Change the id and secret with properly generated from BankLambda
config :bluecode_connector, BankLambda,
  client_id: "b599bd9fdce794fb219a5ef938e599aba5b4eb1f7ee3994d96509ea2a0e0213e",
  client_secret: "8d182d4605f0a723e2d58d021f91419e99d94627eb0ef381bbcd8f89b47bd70c",
  redirect_uri: "http://localhost:4001/wizard/callback",
  strategy: OAuth2.Strategy.AuthCode,
  site: "http://localhost:4000",
  authorize_url: "/oauth/authorize",
  token_url: "/oauth/token"

import_config "#{Mix.env()}.exs"
