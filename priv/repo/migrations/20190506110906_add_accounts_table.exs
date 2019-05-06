defmodule BluecodeConnector.Repo.Migrations.AddAccountsTable do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add(:contract_number, :string)
      add(:card_request_token, :text)
      add(:oauth_code, :text)
      add(:iban, :string)

      timestamps()
    end
  end
end
