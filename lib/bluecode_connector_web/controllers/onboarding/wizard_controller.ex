defmodule BluecodeConnectorWeb.Onboarding.WizardController do
  use BluecodeConnectorWeb, :controller

  alias BluecodeConnector.BankLambda
  alias BluecodeConnector.Bluecode.ContractsApiClient

  def index(conn, %{"jwt" => jwt}) do
    render(conn, "index.html", jwt: jwt)
  end

  def new(conn, %{"jwt" => jwt}) do
    contract_number = UUID.uuid4()

    BankLambda.create_account(%{
      "card_request_token" => jwt,
      "contract_number" => contract_number
    })

    url =
      BluecodeConnector.BankLambda.OauthClient.authorize_url!([], %{
        contract_number: contract_number
      })

    redirect(conn, external: url)
  end

  def callback(conn, %{"code" => code, "contract_number" => contract_number}) do
    account = BankLambda.get_account_by!(contract_number: contract_number)

    BankLambda.update_account(account, %{"oauth_code" => code})

    # THIS NEEDS TO BE FIXED. DOES NOT WORK !
    # client = ContractsApiClient.new("BANK_BLAU", "secret")

    # ContractsApiClient.create_contract(client, %ContractsApiClient.Contract{
    #   contract_number: contract_number,
    #   bank_name: "Paydirekt"
    # })

    # ContractsApiClient.create_card(client, %{
    #   contract_number: account.contract_number,
    #   card_request_token: account.card_request_token
    # })

    # TODO

    # - figure out how we redirect back to the application/webview

    # WE DO NOT REALLY NEED THIS RESPONSE HERE.
    # WE WILL NEED THAT WHEN WE ACTUALLY DO THE CALLS
    response =
      BluecodeConnector.BankLambda.OauthClient.get_token!([code: code], %{
        contract_number: contract_number
      })

    text(conn, "Access token: #{response.token.access_token}")
  end
end
