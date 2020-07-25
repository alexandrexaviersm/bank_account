defmodule BankAccountWeb.RegisterCustomerView do
  use BankAccountWeb, :view

  def render("register_customer.json", %{account: account}) do
    %{
      status: "ok",
      data: %{
        status: account.status,
        referral_code_to_be_shared: account.referral_code_to_be_shared
      }
    }
  end
end
