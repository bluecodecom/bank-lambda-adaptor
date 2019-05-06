defmodule BluecodeConnector.BankLambda.OauthClient do
  use OAuth2.Strategy

  alias OAuth2.Strategy.AuthCode

  # Public API

  def client do
    Application.get_env(:bluecode_connector, BankLambda)
    |> OAuth2.Client.new()
    |> OAuth2.Client.put_serializer("application/json", Jason)
  end

  def authorize_url!(params \\ []) do
    OAuth2.Client.authorize_url!(client(), params)
  end

  def get_token!(params \\ [], _headers \\ []) do
    client = client()

    OAuth2.Client.get_token!(
      client,
      Keyword.merge(params, client_secret: client.client_secret)
    )
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    IO.inspect("11111111111")
    AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    IO.inspect("222222222222")

    client
    |> put_param(:client_secret, client.client_secret)
    |> put_header("Accept", "application/json")
    |> AuthCode.get_token(params, headers)
  end
end
