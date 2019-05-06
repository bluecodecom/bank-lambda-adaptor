defmodule BluecodeConnectorWeb.Onboarding.WizardController do
  use BluecodeConnectorWeb, :controller
  alias BluecodeConnector.BankLambda

  def index(conn, %{"jwt" => jwt}) do
    render(conn, "index.html", jwt: jwt)
  end

  def new(conn, %{"jwt" => jwt}) do
    contract_number = UUID.uuid4()

    redirect(conn,
      external:
        BluecodeConnector.BankLambda.OauthClient.authorize_url!([], %{
          contract_number: contract_number
        })
    )
  end

  def callback(conn, %{"code" => code, "contract_number" => contract_number}) do
    # TODO
    # - persist the code in the account and use it to get token in the future clearing controller
    # - the token is here client.token.access_token

    # - create the BlueCode contract
    # - craete the BlueCode card

    # - figure out how we redirect back to the application/webview
    response =
      BluecodeConnector.BankLambda.OauthClient.get_token!([code: code], %{
        contract_number: contract_number
      })

    text(conn, "Access token: #{response.token.access_token}")
  end
end
