defmodule BluecodeConnector.Repo.Migrations.AddOauthTokenToAccounts do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add(:oauth_token, :text)
    end
  end
end
