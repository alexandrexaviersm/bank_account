defmodule BankAccount.Repo.Migrations.CreateCustomers do
  use Ecto.Migration

  def change do
    create table(:customers) do
      add :name, :string
      add :email, :string
      add :cpf, :string, null: false
      add :birth_date, :date
      add :gender, :string
      add :city, :string
      add :state, :string
      add :country, :string
      add :referral_code, :string

      timestamps()
    end
  end
end
