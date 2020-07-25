defmodule BankAccountWeb.RegisterCustomerController do
  use BankAccountWeb, :controller

  alias BankAccount.RegisterCustomer

  def create(conn, params) do
    params = for {key, val} <- params, into: %{}, do: {String.to_atom(key), val}

    case RegisterCustomer.run(params) do
      {:ok, {_customer, account}} ->
        render(conn, "register_customer.json", %{account: account})

      {:error, :cpf_already_exists} ->
        conn
        |> put_status(401)
        |> json(%{status: "unauthenticated"})

      {:error, _} ->
        conn
        |> put_status(401)
        |> json(%{status: "unauthenticated"})
    end
  end
end
