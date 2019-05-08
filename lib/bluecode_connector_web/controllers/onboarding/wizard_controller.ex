defmodule BluecodeConnectorWeb.Onboarding.WizardController do
  use BluecodeConnectorWeb, :controller

  alias BluecodeConnector.MappingTables
  alias BluecodeConnector.BankLambda.OauthClient
  alias BluecodeConnector.BankLambda.AispApiClient

  alias BluecodeConnector.Bluecode.ContractsApiClient

  def index(conn, %{"jwt" => jwt}) do
    wallet_id = extract_wallet_id(jwt)

    render(conn, "index.html", jwt: jwt, wallet_id: wallet_id)
  end

  def new(conn, %{"jwt" => jwt}) do
    contract_number = "anon_#{:crypto.rand_uniform(1_000_000, 9_000_000)}"

    MappingTables.create_account(%{
      "card_request_token" => jwt,
      "contract_number" => contract_number
    })

    url =
      OauthClient.authorize_url!([], %{
        contract_number: contract_number
      })

    redirect(conn, external: url)
  end

  def callback(conn, %{"code" => oauth_code, "contract_number" => contract_number}) do
    with account <- MappingTables.get_account_by!(contract_number: contract_number),
         {:ok, account} <- update_oauth_token(account, oauth_code),
         {:ok, account, account_name} <- update_account_iban(account) do
      # We have all information from Bank Lambda AISP. Now create connection to bluecode.

      # TODO: move into the with pipeline:
      create_bluecode_contract(account.contract_number)
      create_bluecode_card(account.contract_number, account.card_request_token, account_name)

      # TODO: don't, only for demonstration and debugging information.
      wallet_id = extract_wallet_id(account.card_request_token)

      render(
        conn,
        "success.html",
        access_token: account.oauth_token,
        account_name: account_name,
        contract_number: contract_number,
        wallet_id: wallet_id,
        iban: account.iban
      )
    end
  end

  defp update_oauth_token(account, code) do
    response =
      OauthClient.get_token!([code: code], %{
        contract_number: account.contract_number
      })

    {:ok, account} =
      MappingTables.update_account(account, %{
        oauth_code: code,
        oauth_token: response.token.access_token
      })

    {:ok, account}
  end

  defp update_account_iban(account) do
    {:ok, %{body: accounts}} =
      AispApiClient.new(%{access_token: account.oauth_token})
      |> AispApiClient.accounts()

    main_acct = List.first(accounts["accounts"])
    iban = main_acct["iban"]
    account_name = main_acct["name"]

    {:ok, account} = MappingTables.update_account(account, %{iban: iban})

    {:ok, account, account_name}
  end

  defp create_bluecode_contract(contract_number) do
    member_id = Application.get_env(:bluecode_connector, :bluecode_member_id)

    resp =
      contracts_api_client()
      |> ContractsApiClient.create_contract(%ContractsApiClient.Contract{
        contract_number: contract_number,
        member_id: member_id
      })

    # TODO: handle responses
    {:ok, resp}
  end

  defp create_bluecode_card(contract_number, card_request_token, display_name) do
    resp =
      contracts_api_client()
      |> ContractsApiClient.create_card(%{
        contract_number: contract_number,
        display_name: display_name,
        card_request_token: card_request_token
      })

    # TODO: handle responses
    {:ok, resp}
  end

  defp contracts_api_client() do
    bc_auth = Application.get_env(:bluecode_connector, :bc_auth)
    ContractsApiClient.new(bc_auth[:username], bc_auth[:password])
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
