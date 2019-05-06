defmodule BluecodeConnectorWeb.ClearingApi.ClearingController do
  @moduledoc """
  Implementation of Clearing API v1
  """
  use BluecodeConnectorWeb, :controller

  alias BluecodeConnector.Repo
  alias BluecodeConnector.BankLambda.Account
  alias BluecodeConnector.BankLambda.PaymentsApiClient
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
            # Transparently pass back the paymentId created by Bank Lambda
            issuer_tx_ref: resp["paymentId"],
            issuer_txevent_ref: resp["paymentId"],
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

    {:ok, %{body: body}} =
      PaymentsApiClient.new(%{access_token: acct.oauth_token})
      |> PaymentsApiClient.payment!(params)

    case body do
      %{"transactionStatus" => "ACCC"} ->
        {:ok, body}

      _ ->
        {:error, %{body: body}}
    end
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
