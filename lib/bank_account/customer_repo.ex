defmodule BankAccount.CustomerRepo do
  @moduledoc """
  Customer repository
  """
  import Ecto.Query, only: [from: 2]

  alias BankAccount.Repo
  alias BankAccount.Schema.{Account, Customer}

  def get_customer(id) do
    case Repo.get(Customer, id) do
      nil -> {:error, :customer_not_found}
      %Customer{} = customer -> {:ok, customer}
    end
  end

  def get_customer!(id) do
    Repo.get!(Customer, id)
  end

  def get_customers_by_referral_code(referral_code) do
    from(c in Customer,
      where: c.referral_code == ^referral_code,
      select: %{
        id: c.id,
        encrypted_name_to_be_shared: c.encrypted_name_to_be_shared,
        unique_salt: c.unique_salt
      }
    )
    |> Repo.all()
  end

  def referral_code_exists?(referral_code) do
    from(a in Account, where: a.referral_code_to_be_shared == ^referral_code)
    |> Repo.exists?()
  end

  def find_customer_by_cpf(nil), do: nil

  def find_customer_by_cpf(cpf) do
    Repo.all(Customer)
    |> Enum.find(fn customer ->
      Bcrypt.verify_pass(cpf, customer.cpf_hash)
    end)
  end
end
