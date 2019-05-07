defmodule BluecodeConnectorWeb.Onboarding.WizardController do
  use BluecodeConnectorWeb, :controller

  alias BluecodeConnector.BankLambda
  alias BluecodeConnector.Bluecode.ContractsApiClient

  def index(conn, %{"jwt" => jwt}) do
    wallet_id = extract_wallet_id(jwt)

    render(conn, "index.html", jwt: jwt, wallet_id: wallet_id)
  end

  def new(conn, %{"jwt" => jwt}) do
    contract_number = "anon_#{:crypto.rand_uniform(1_000_000, 9_000_000)}"

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

    # WE DO NOT REALLY NEED THIS RESPONSE HERE.
    # WE WILL NEED THAT WHEN WE ACTUALLY DO THE CALLS
    response =
      BluecodeConnector.BankLambda.OauthClient.get_token!([code: code], %{
        contract_number: contract_number
      })

    BankLambda.update_account(account, %{
      oauth_code: code,
      oauth_token: response.token.access_token
    })

    account_name = "Checking Account"

    client = ContractsApiClient.new("BANK_BLAU", "secret")

    # {:ok, _} =
    ContractsApiClient.create_contract(client, %ContractsApiClient.Contract{
      contract_number: contract_number,
      member_id: "ATA0000001"
    })

    # {:ok, _} =
    ContractsApiClient.create_card(client, %{
      contract_number: account.contract_number,
      display_name: account_name,
      card_request_token: account.card_request_token
    })

    wallet_id = extract_wallet_id(account.card_request_token)

    render(
      conn,
      "success.html",
      access_token: response.token.access_token,
      account_name: account_name,
      contract_number: contract_number,
      wallet_id: wallet_id,
      iban: account.iban
    )
  end

  defp extract_wallet_id(jwt) do
    %JOSE.JWT{fields: payload} = JOSE.JWT.peek_payload(jwt)

    wallet_id =
      payload["wid"]
      |> String.trim_leading("wlt_")

    wids = String.split(wallet_id, "-")

    "#{hd(wids)}-...-#{List.last(wids)}"
  end
end
