defmodule BluecodeConnector.BankLambda.ClearingApiClientTest do
  use ExUnit.Case, async: true
  alias BluecodeConnector.BankLambda.PaymentsApiClient

  test "makes payment" do
    {:ok, %{body: body}} =
      PaymentsApiClient.new(%{
        access_token: "8329ca0bf1c75dd6ccc1fb215c1ce0ea55df913dd9422cf34ba2afabf5fb169c"
      })
      |> PaymentsApiClient.payment!()

    assert body["status"] == "ok"
  end
end
