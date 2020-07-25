defmodule BankAccountWeb.RegisterCustomerViewTest do
  use ExUnit.Case, async: true

  alias BankAccountWeb.RegisterCustomerView

  setup :account_attrs

  test "tender/2 returns ok and the account information", %{account: account} do
    assert %{status: "ok", data: %{status: "complete", referral_code_to_be_shared: "12345678"}} =
             RegisterCustomerView.render("register_customer.json", %{account: account})
  end

  defp account_attrs(_context) do
    [
      account: %{
        status: "complete",
        referral_code_to_be_shared: "12345678"
      }
    ]
  end
end
