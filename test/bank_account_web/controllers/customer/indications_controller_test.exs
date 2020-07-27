defmodule BankAccountWeb.Customer.IndicationsControllerTest do
  use BankAccountWeb.ConnCase, async: true

  import BankAccountWeb.CustomerAuth

  alias BankAccount.{Factories, Factory}

  describe "show/2" do
    setup %{conn: conn} do
      customer =
        [encrypted_name_to_be_shared: "4/d5Pkq5DQdD9kBttSUuuirCN4datxsKQm9i1pD4b6NcroIq"]
        |> Factories.customer()
        |> Factory.insert!()

      [customer_id: customer.id, referral_code_to_be_shared: "12345678", status: :complete]
      |> Factories.account()
      |> Factory.insert!()

      conn = authenticate(conn, customer)

      %{conn: conn}
    end

    test "returns 200 when customer is authenticate", %{conn: conn} do
      conn = post(conn, "/api/v1/customers/indications")

      assert %{
               "status" => "ok",
               "data" => [%{"customer_id" => _, "customer_name" => _}]
             } = json_response(conn, 200)
    end
  end
end
