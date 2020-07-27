defmodule BankAccount.Factories do
  @moduledoc """
    Test Factories
  """

  alias BankAccount.Enums.AccountStatus
  alias BankAccount.Schema.{Account, Customer}
  alias Ecto.UUID

  @spec account(keyword()) :: Account.t()
  def account(attrs \\ []) do
    attrs =
      [
        customer_id: UUID.generate(),
        referral_code_to_be_shared: "87654321",
        status: AccountStatus.get_from_key(:pending)
      ]
      |> Keyword.merge(attrs)

    struct(Account, attrs)
  end

  @spec customer(keyword()) :: Customer.t()
  def customer(attrs \\ []) do
    cpf = CPF.generate() |> CPF.format()

    attrs =
      [
        cpf_hash: cpf,
        referral_code: "12345678",
        unique_salt: "gxkjIEU2BXTjzQCAzVJh4g=="
      ]
      |> Keyword.merge(attrs)

    struct(Customer, attrs)
  end
end
