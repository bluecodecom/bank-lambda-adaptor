# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :bluecode_connector, ecto_repos: [BluecodeConnector.Repo]

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
  redirect_uri: "https://lambda-bluecode.#{System.get_env("BC_DEV_DOMAIN")}/wizard/callback",
  strategy: OAuth2.Strategy.AuthCode,
  site: "https://bank-lambda.#{System.get_env("BC_DEV_DOMAIN")}",
  authorize_url: "/oauth/authorize",
  token_url: "/oauth/token"

config :bluecode_connector, :bc_auth,
  username: System.get_env("BC_ADAPTER_USERNAME"),
  password: System.get_env("BC_ADAPTER_PASSWORD")

config :bluecode_connector, :bluecode_member_id, "DEI0000099"

import_config "#{Mix.env()}.exs"

# Note: import_config/1 is relative to this file, File.exists?/1 isn't
if File.exists?("#{Path.dirname(__ENV__.file)}/#{Mix.env()}.local.exs") do
  import_config "#{Mix.env()}.local.exs"
end
