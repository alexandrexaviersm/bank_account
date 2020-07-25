defmodule BankAccountWeb.Guardian do
  @moduledoc """
  JWT Aithentication
  """
  use Guardian, otp_app: :bank_account

  alias BankAccount.CustomerRepo

  def subject_for_token(resource, _claims) do
    sub = to_string(resource.id)
    {:ok, sub}
  end

  def resource_from_claims(claims) do
    id = claims["sub"]
    resource = CustomerRepo.get_customer!(id)
    {:ok, resource}
  end
end
