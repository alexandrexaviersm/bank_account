defmodule BankAccount.CreateCustomerTest do
  use BankAccount.DataCase, async: true

  alias BankAccount.{CreateCustomer, Customer}
  alias Ecto.Changeset

  setup :create_customer_params

  describe "run/1" do
    test "returns a struct when the params are valid", %{params: %{cpf: cpf} = params} do
      assert {:ok, %Customer{} = customer} = CreateCustomer.run(params)

      assert customer.city == "Mirassol"
      assert customer.country == "BR"
      assert customer.state == "SP"
      assert customer.gender == :not_identify
      assert customer.referral_code == "12345678"
      assert customer.encrypted_name
      assert customer.encrypted_email
      assert customer.encrypted_cpf
      assert customer.encrypted_birth_date

      # sensitive data cannot be save in plain text
      refute customer.encrypted_name == "Foo"
      refute customer.encrypted_email == "foo@bar.com"
      refute customer.encrypted_cpf == cpf
      refute customer.encrypted_birth_date == "1990-01-01"
    end

    test "should create a salt hash for customer", %{params: params} do
      assert {:ok, %Customer{} = customer} = CreateCustomer.run(params)

      assert customer.unique_salt
    end

    test "returns a struct when only the cpf is passed" do
      cpf = CPF.generate() |> CPF.format()
      params = %{cpf: cpf}

      assert {:ok, %Customer{} = customer} = CreateCustomer.run(params)
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

    test "returns error when name lenght is bigger than 100 characters", %{params: params} do
      invalid_params = %{params | name: String.duplicate("a", 101)}

      assert {:error, %Changeset{} = changeset} = CreateCustomer.run(invalid_params)
      assert "should be at most 100 character(s)" in errors_on(changeset).name
    end

    test "returns error when name lenght is less than 3 characters", %{params: params} do
      invalid_params = %{params | name: "aa"}

      assert {:error, %Changeset{} = changeset} = CreateCustomer.run(invalid_params)
      assert "should be at least 3 character(s)" in errors_on(changeset).name
    end

    test "returns error when name isn't a string", %{params: params} do
      for invalid_name <- [nil, true, 123, 1.1, %{}, [], {}] do
        invalid_params = %{params | name: invalid_name}

        assert {:error, %Changeset{} = changeset} = CreateCustomer.run(invalid_params)
        assert "is invalid" in errors_on(changeset).name
      end
    end

    test "returns error when city name is bigger than 50 characters", %{params: params} do
      invalid_params = %{params | city: String.duplicate("a", 51)}

      assert {:error, %Changeset{} = changeset} = CreateCustomer.run(invalid_params)
      assert "should be at most 50 character(s)" in errors_on(changeset).city
    end

    test "returns error when city name is less than 3 characters", %{params: params} do
      invalid_params = %{params | city: "aa"}

      assert {:error, %Changeset{} = changeset} = CreateCustomer.run(invalid_params)
      assert "should be at least 3 character(s)" in errors_on(changeset).city
    end

    test "returns error when the length of the country code is different than 2 characters", %{
      params: params
    } do
      invalid_params = %{params | country: "United States"}

      assert {:error, %Changeset{} = changeset} = CreateCustomer.run(invalid_params)
      assert "should be 2 character(s)" in errors_on(changeset).country
    end

    test "returns error when the country code doesn't exist", %{
      params: params
    } do
      invalid_params = %{params | country: "AA"}

      assert {:error, %Changeset{} = changeset} = CreateCustomer.run(invalid_params)
      assert "is invalid" in errors_on(changeset).country
    end

    test "returns error when the length of the state code is different than 2 characters", %{
      params: params
    } do
      invalid_params = %{params | state: "sao paulo"}

      assert {:error, %Changeset{} = changeset} = CreateCustomer.run(invalid_params)
      assert "should be 2 character(s)" in errors_on(changeset).state
    end

    test "returns error when the length of the referral_code is different than 8 characters", %{
      params: params
    } do
      invalid_params = %{params | referral_code: "123456789"}

      assert {:error, %Changeset{} = changeset} = CreateCustomer.run(invalid_params)
      assert "should be 8 character(s)" in errors_on(changeset).referral_code
    end

    test "returns error when the gender isn't configured in the module Enums.GenderType", %{
      params: params
    } do
      invalid_params = %{params | gender: "invalid_value"}

      assert {:error, %Changeset{} = changeset} = CreateCustomer.run(invalid_params)
      assert "is invalid" in errors_on(changeset).gender
    end
  end

  defp create_customer_params(_context) do
    cpf = CPF.generate() |> CPF.format()

    [
      params: %{
        name: "Foo",
        email: "foo@bar.com",
        cpf: cpf,
        birth_date: "1990-01-01",
        city: "Mirassol",
        country: "BR",
        state: "SP",
        gender: "not_identify",
        referral_code: "12345678"
      }
    ]
  end
end
