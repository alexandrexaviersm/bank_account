defmodule BankAccount.CustomerRepo do
  @moduledoc """
  Customer repository
  """
  alias BankAccount.Repo
  alias BankAccount.Schema.Customer

  def get_customer!(id) do
    Repo.get_by!(Customer, id)
  end

  def find_customer_by_cpf(cpf) do
    Repo.all(Customer)
    |> Enum.find(fn customer ->
      Bcrypt.verify_pass(cpf, customer.cpf_hash)
    end)
  end
end
