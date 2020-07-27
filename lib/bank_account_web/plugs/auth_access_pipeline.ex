defmodule BankAccountWeb.AuthAccessPipeline do
  @moduledoc """
  Guardian Auth Pipeline
  """
  use Guardian.Plug.Pipeline, otp_app: :bank_account

  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
