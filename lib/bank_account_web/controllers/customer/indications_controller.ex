defmodule BankAccountWeb.Customer.IndicationsController do
  use BankAccountWeb, :controller

  alias BankAccount.DisplayIndications

  def show(conn, _params) do
    customer = Guardian.Plug.current_resource(conn)

    case DisplayIndications.run(customer) do
      {:error, :account_must_be_complete} ->
        conn
        |> put_status(422)
        |> json(%{status: "unprocessable entity", detail: "Account must be completed!"})

      {:error, :unauthenticated} ->
        conn
        |> put_status(401)
        |> json(%{status: "unauthenticated"})

      customers ->
        conn
        |> put_status(200)
        |> render("display_indications.json", %{customers: customers})
    end
  end
end
