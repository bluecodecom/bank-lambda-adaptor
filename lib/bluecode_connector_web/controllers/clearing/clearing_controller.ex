defmodule BluecodeConnectorWeb.ClearingApi.ClearingController do
  @moduledoc """
  Implementation of Clearing API v1
  """
  use BluecodeConnectorWeb, :controller

  alias BluecodeConnector.Repo
  alias BluecodeConnector.BankLambda.Account

  require Logger

  @doc """
  Tries to insert a record and swallows any exceptions.

  """
  def payment(conn, %{"contract_number" => contract_number} = params) do
    with {:ok, acct} <- find_account(contract_number),
         {:ok, resp} <- post_instant_payment(acct, params) do
      conn
      |> put_status(201)
      |> json(%{
        status: "OK",
        code: "CLEARED",
        messages: [],
        data: %{
          tx: %{
            issuer_tx_ref: resp["id"],
            issuer_txevent_ref: resp["id"],
            issuer_txevent_time: :os.system_time(:millisecond),
            tx_state: "CLEARED"
          }
        }
      })
    else
      {:error, :account_not_found} ->
        conn
        |> put_status(400)
        |> json(%{
          status: "ERROR",
          code: "ERROR_INVALID_ROUTING",
          messages: [],
          data: %{}
        })
    end
  end

  # Calls the PIS payment endpoint
  defp post_instant_payment(%Account{} = acct, params) do
    params = %{
      debtorAccount: %{iban: acct.iban},
      creditorAccount: %{iban: params["merchant_iban"]},
      instructedAmount: %{currency: "EUR", amount: params["amount"]},
      creditorName: params["merchant_name"],
      endToEndIdentification: params["bc_tx_id"],
      remittanceInformationUnstructured: params["merchant_tx_id"]
    }

    headers = [
      access_token: acct.oauth_token
    ]

    # TODO: Call api here of fake simulator
    # resp = psd2_client.post("/v1/payments/instant-sepa-...", headers, params)
    # if resp["state"] == "ACPT" do ...

    {:ok,
     %{
       id: UUID.uuid4()
     }}
  end

  defp find_account(contract_number) do
    case Repo.get_by(Account, contract_number: contract_number) do
      nil ->
        {:error, :account_not_found}

      acct ->
        {:ok, acct}
    end
  end
end
