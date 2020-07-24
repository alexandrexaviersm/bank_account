defmodule BankAccount.Repo.Migrations.CreateCustomers do
  use Ecto.Migration

  alias BankAccount.Enums.GenderType

  def change do
    create table(:customers, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :city, :string
      add :country, :string
      add :encrypted_name, :string
      add :encrypted_name_to_be_shared, :string
      add :encrypted_email, :string
      add :encrypted_cpf, :string, null: false
      add :encrypted_birth_date, :string
      add :gender, GenderType.type()
      add :referral_code, :string, size: 8
      add :state, :string
      add :unique_salt, :string, null: false

      timestamps()
    end
  end
end
