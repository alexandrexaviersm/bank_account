# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :bank_account,
  ecto_repos: [BankAccount.Repo]

# Configures the endpoint
config :bank_account, BankAccountWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "3Z6/4LpOM7DV6+K707712nIV3Wf83U+a03D5l7eBviodfU8r9nX2sSnNG4kyp6rM",
  render_errors: [view: BankAccountWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: BankAccount.PubSub,
  live_view: [signing_salt: "0aH96L1X"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :bank_account, BankAccountWeb.Guardian,
  issuer: "bank_account",
  secret_key: "FcDgJ+zJtxJRFj5fXoX0Txrr2lX59AH+6dXcqrQLuinzknBYsiPm1L+zHW12vnfT"

config :bank_account, BankAccountWeb.AuthAccessPipeline,
  module: BankAccountWeb.Guardian,
  error_handler: BankAccountWeb.AuthErrorHandler

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
