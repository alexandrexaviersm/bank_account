defmodule BankAccount.CreateCustomerTest do
  use BankAccount.DataCase, async: true

  alias BankAccount.{CreateCustomer, Customer}
  alias Ecto.Changeset

  setup :create_customer_params

  describe "run/1" do
    test "returns a struct when the params are valid", %{params: %{cpf: cpf} = params} do
      assert {:ok, %Customer{} = customer} = CreateCustomer.run(params)
      assert customer.city == "Mirassol"
      assert customer.country == "Brasil"
      assert customer.state == "SP"
      assert customer.gender == :not_identify
      assert customer.referral_code == "12345678"

      # sensitive data cannot be save in plain text
      refute customer.encrypted_name == "Foo"
      refute customer.encrypted_email == "foo@bar.com"
      refute customer.encrypted_cpf == cpf
      refute customer.encrypted_birth_date == ~D[1994-03-21]
    end

    test "returns error when cpf is missing", %{params: params} do
      invalid_params = Map.drop(params, [:cpf])

      assert {:error, %Changeset{} = changeset} = CreateCustomer.run(invalid_params)
      assert "can't be blank" in errors_on(changeset).cpf
    end

    test "returns error when cpf is invalid", %{params: params} do
      invalid_params = %{params | cpf: ""}

      assert {:error, %Changeset{} = changeset} = CreateCustomer.run(invalid_params)
      assert "is invalid" in errors_on(changeset).cpf
    end
  end

  defp create_customer_params(_context) do
    cpf = CPF.generate() |> CPF.format()

    [
      params: %{
        name: "Foo",
        email: "foo@bar.com",
        cpf: cpf,
        birth_date: ~D[1994-03-21],
        city: "Mirassol",
        country: "Brasil",
        state: "SP",
        gender: "not_identify",
        referral_code: "12345678"
      }
    ]
  end
end
