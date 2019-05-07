defmodule BluecodeConnector.BankLambda.AispApiClient do
  use Tesla

  def new(params) do
    Tesla.client([
      {Tesla.Middleware.BaseUrl,
       "https://bank-lambda.#{System.get_env("BC_DEV_DOMAIN")}/api/v1/"},
      {Tesla.Middleware.Headers,
       [
         {"authorization", "Bearer #{params.access_token}"}
       ]},
      Tesla.Middleware.JSON,
      Tesla.Middleware.Logger
    ])
  end

  def accounts(client) do
    get(client, "/accounts")
  end
end
