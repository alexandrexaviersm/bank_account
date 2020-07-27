defmodule BankAccountWeb.Customer.IndicationsView do
  use BankAccountWeb, :view

  def render("display_indications.json", %{customers: customers}) do
    data = Enum.map(customers, & &1)

    %{
      status: "ok",
      data: data
    }
  end
end
