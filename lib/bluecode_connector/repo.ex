defmodule BluecodeConnector.Repo do
  use Ecto.Repo,
    otp_app: :bluecode_connector,
    adapter: Ecto.Adapters.Postgres
end
