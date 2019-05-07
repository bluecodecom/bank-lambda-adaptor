defmodule BluecodeConnector.BankLambda.PispApiClient do
  use Tesla

  def new(params) do
    Tesla.client([
      {Tesla.Middleware.BaseUrl,
       "https://bank-lambda.#{System.get_env("BC_DEV_DOMAIN")}/api/v1/payments"},
      {Tesla.Middleware.Headers,
       [
         {"authorization", "Bearer #{params.access_token}"}
       ]},
      Tesla.Middleware.JSON,
      Tesla.Middleware.Logger
    ])
  end

  def payment!(client, params \\ %{}) do
    post(client, "/instant-sepa-credit-transfers", params)
  end
end
