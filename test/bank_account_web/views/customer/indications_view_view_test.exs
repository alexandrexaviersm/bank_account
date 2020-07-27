defmodule BankAccountWeb.Customer.IndicationsViewTest do
  use ExUnit.Case, async: true

  alias BankAccountWeb.Customer.IndicationsView

  setup :account_attrs

  test "tender/2 returns ok and the account information", %{customers: customers} do
    assert %{
             status: "ok",
             data: [
               %{customer_id: _, customer_name: "Foo Bar"},
               %{customer_id: _, customer_name: "Foo Bar 2"}
             ]
           } = IndicationsView.render("display_indications.json", %{customers: customers})
  end

  defp account_attrs(_context) do
    [
      customers: [
        %{customer_id: Ecto.UUID.generate(), customer_name: "Foo Bar"},
        %{customer_id: Ecto.UUID.generate(), customer_name: "Foo Bar 2"}
      ]
    ]
  end
end
