defmodule BluecodeConnector.BankLambda.OauthClient do
  use OAuth2.Strategy

  alias OAuth2.Strategy.AuthCode

  # Public API

  def client(query_params) do
    client =
      Application.get_env(:bluecode_connector, BankLambda)
      |> OAuth2.Client.new()
      |> OAuth2.Client.put_serializer("application/json", Jason)

    query_params = URI.encode_query(query_params)
    redirect_uri = client.redirect_uri <> "?" <> query_params

    %{client | redirect_uri: redirect_uri}
  end

  def authorize_url!(params, query_params) do
    client = client(query_params)

    OAuth2.Client.authorize_url!(client, params)
  end

  def get_token!(params, query_params) do
    client = client(query_params)

    OAuth2.Client.get_token!(
      client,
      Keyword.merge(params, client_secret: client.client_secret)
    )
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_param(:client_secret, client.client_secret)
    |> put_header("Accept", "application/json")
    |> AuthCode.get_token(params, headers)
  end
end
