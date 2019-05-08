defmodule BluecodeConnector.MappingTables.Account do
  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field(:contract_number, :string)

    # Temporary card_request_token, can be discarded after contract was
    # connected to a card (and store card_id instead).
    field(:card_request_token, :string)

    field(:oauth_code, :string)
    # TODO: store oauth_token encrypted in database
    field(:oauth_token, :string)

    # Required for PISP calls.
    # TODO: store iban encrypted in database
    field(:iban, :string)

    timestamps()
  end

  def changeset(account, attrs) do
    account
    |> cast(attrs, [:contract_number, :card_request_token, :oauth_code, :iban, :oauth_token])
  end
end
