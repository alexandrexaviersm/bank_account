defmodule BankAccount.Repo.Migrations.RenameFieldEncryptedCpfFromCustomers do
  use Ecto.Migration

  def change do
    rename table(:customers), :encrypted_cpf, to: :cpf_hash
  end
end
