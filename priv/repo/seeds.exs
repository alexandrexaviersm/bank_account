# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     BankAccount.Repo.insert!(%BankAccount.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

import Ecto.Changeset

alias BankAccount.Schema.{Account, Customer}

customer_attrs = %{
  referral_code: "xxxxxxxx",
  cpf_hash: "cpf_hash",
  encrypted_name: "base_user",
  unique_salt: "xxxxxxxx"
}

{:ok, customer} =
  %Customer{}
  |> cast(customer_attrs, [:encrypted_name, :cpf_hash, :referral_code, :unique_salt])
  |> BankAccount.Repo.insert()

account_attrs = %{customer_id: customer.id, referral_code_to_be_shared: "12345678"}

%Account{}
|> cast(account_attrs, [:customer_id, :referral_code_to_be_shared])
|> BankAccount.Repo.insert()
