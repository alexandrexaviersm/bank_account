defmodule BankAccountWeb.CustomerAuth do
  @moduledoc """
  Authenticate requests as admin
  """

  import Plug.Conn

  alias BankAccountWeb.Guardian

  def authenticate(conn, customer) do
    {:ok, token, _} = Guardian.encode_and_sign(customer)

    put_req_header(conn, "authorization", "Bearer " <> token)
  end
end
