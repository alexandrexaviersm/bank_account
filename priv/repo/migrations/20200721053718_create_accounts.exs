defmodule BankAccount.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :status, :string
      add :referral_code, :string
      add :customer_id, references(:customers, on_delete: :nothing)

      timestamps()
    end

    create index(:accounts, [:customer_id])
  end
end
