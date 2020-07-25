defmodule BankAccount.Factories do
  @moduledoc """
    Test Factories
  """

  alias BankAccount.Enums.{AccountStatus, GenderType}
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
        name: "Foo",
        email: "foo@bar.com",
        cpf: cpf,
        birth_date: "1990-01-01",
        city: "São Paulo",
        country: "BR",
        state: "SP",
        gender: GenderType.get_from_key(:not_identify),
        referral_code: "12345678"
      ]
      |> Keyword.merge(attrs)

    struct(Customer, attrs)
  end
end
