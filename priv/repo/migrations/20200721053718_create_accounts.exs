defmodule BankAccount.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  alias BankAccount.Enums.AccountStatus

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :status, AccountStatus.type(),
        null: false,
        default: :pending

      add :referral_code_to_be_shared, :string, size: 8
      add :customer_id, references(:customers, on_delete: :nothing, type: :uuid)

      timestamps()
    end

    create index(:accounts, [:customer_id])
  end
end
