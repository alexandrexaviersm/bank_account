defmodule BankAccountWeb.Customer.RegisterController do
  use BankAccountWeb, :controller

  import BankAccountWeb.ErrorHelpers

  alias BankAccount.RegisterCustomer
  alias BankAccountWeb.Guardian
  alias Ecto.Changeset

  def update(conn, params) do
    params = to_map(params)

    case CPF.valid?(params[:cpf]) do
      true ->
        params = %{params | cpf: CPF.parse!(params[:cpf]) |> to_string()}

        case RegisterCustomer.run(params) do
          {:ok, {customer, account}} ->
            {:ok, token, _} = Guardian.encode_and_sign(customer)

            conn
            |> put_resp_header("jwt_token", token)
            |> put_status(200)
            |> render("register_customer.json", %{account: account})

          {:ok, {:account_already_complete, account, customer}} ->
            {:ok, token, _} = Guardian.encode_and_sign(customer)

            conn
            |> put_resp_header("jwt_token", token)
            |> put_status(200)
            |> json(%{
              status: "ok",
              detail: "Account already completed!",
              referral_code_to_be_shared: account.referral_code_to_be_shared
            })

          {:error, changeset} ->
            conn
            |> put_status(422)
            |> json(%{
              status: "unprocessable entity",
              errors: Changeset.traverse_errors(changeset, &translate_error/1)
            })
        end

      false ->
        conn
        |> put_status(422)
        |> json(%{status: "unprocessable entity", detail: "CPF is not valid!"})
    end
  end

  defp to_map(params), do: for({key, val} <- params, into: %{}, do: {String.to_atom(key), val})
end
