defmodule BluecodeConnectorWeb.Onboarding.WizardController do
  use BluecodeConnectorWeb, :controller

  def index(conn, _params) do
    # TODO
    # - generate contract number
    # - persist an account with incoming params

    render(conn, "index.html")
  end

  def new(conn, _params) do
    # TODO
    #  add contract number  as param to the authorize_url!

    redirect(conn, external: BluecodeConnector.BankLambda.OauthClient.authorize_url!())
  end

  def callback(conn, %{"code" => code}) do
    # TODO
    # - persist the code in the account and use it to get token in the future clearing controller
    # - the token is here client.token.access_token
    response = BluecodeConnector.BankLambda.OauthClient.get_token!(code: code)

    # - create the BlueCode contract
    # - craete the BlueCode card

    # - figure out how we redirect back to the application/webview
    text(conn, "Access token: #{response.token.access_token}")
  end
end
