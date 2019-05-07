defmodule BluecodeConnectorWeb.Onboarding.WizardController do
  use BluecodeConnectorWeb, :controller
  alias BluecodeConnector.BankLambda

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
    wallet_id = extract_wallet_id(account.card_request_token)

    BankLambda.update_account(account, %{"oauth_code" => code})
    # TODO

    # - create the BlueCode contract
    # - craete the BlueCode card

    # - figure out how we redirect back to the application/webview

    # WE DO NOT REALLY NEED THIS RESPONSE HERE.
    # WE WILL NEED THAT WHEN WE ACTUALLY DO THE CALLS
    response =
      BluecodeConnector.BankLambda.OauthClient.get_token!([code: code], %{
        contract_number: contract_number
      })

    text(conn, "Access token: #{response.token.access_token}")
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
