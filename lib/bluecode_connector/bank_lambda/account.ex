defmodule BluecodeConnector.BankLambda.Account do
  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field :contract_number, :string
    field :card_request_token, :string
    field :oauth_code, :string
    field :iban, :string
    field :oauth_token, :string

    timestamps()
  end

  def changeset(account, attrs) do
    account
    |> cast(attrs, [:contract_number, :card_request_token, :oauth_code, :iban, :oauth_token])
  end
end
