defmodule BluecodeConnector.BankLambda do
  import Ecto.Query, warn: false
  alias BluecodeConnector.Repo
  alias BluecodeConnector.BankLambda.Account

  def get_account_by!(attributes), do: Repo.get_by!(Account, attributes)

  def create_account(attrs \\ %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  def change_account(%Account{} = account) do
    Account.changeset(account, %{})
  end
end
