defmodule BankAccountWeb.Customer.RegisterControllerTest do
  use BankAccountWeb.ConnCase, async: true

  alias BankAccount.{Factories, Factory}

  describe "create/2" do
    setup :create_customer
    setup :create_customer_params

    test "returns 200 when customer data are valid", %{conn: conn, params: params} do
      conn = patch(conn, "/api/v1/customers/update", params)

      assert %{
               "status" => "ok",
               "data" => %{"status" => "complete", "referral_code_to_be_shared" => _}
             } = json_response(conn, 200)
    end

    test "returns 401 when customer data are invalid", %{conn: conn, params: params} do
      invalid_params = %{params | country: "United States"}
      conn = patch(conn, "/api/v1/customers/update", invalid_params)

      assert %{"status" => "unprocessable entity"} = json_response(conn, 422)
    end
  end

  defp create_customer_params(%{conn: conn}) do
    cpf = CPF.generate() |> CPF.format()

    params = %{
      name: "Foo",
      email: "foo@bar.com",
      cpf: cpf,
      birth_date: "1990-01-01",
      city: "São Paulo",
      country: "BR",
      state: "SP",
      gender: "not_identify",
      referral_code: "12345678"
    }

    [conn: conn, params: params]
  end

  defp create_customer(_context) do
    customer =
      Factories.customer()
      |> Factory.insert!()

    [customer_id: customer.id, referral_code_to_be_shared: "12345678"]
    |> Factories.account()
    |> Factory.insert!()

    []
  end
end
