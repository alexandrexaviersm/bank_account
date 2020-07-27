defmodule BankAccount.DisplayIndications do
  @moduledoc """
  Display customer's indications
  """
  alias BankAccount.CustomerRepo
  alias BankAccount.Repo
  alias BankAccount.Schema.Account
  alias BankAccount.UserEncryption.Security.Utils, as: UserEncryption

  def run(nil) do
    {:error, :unauthenticated}
  end

  def run(customer) do
    with %{account: %Account{} = account} <- Repo.preload(customer, :account),
         :complete <- account.status,
         referral_code = account.referral_code_to_be_shared,
         customers <- CustomerRepo.get_customers_by_referral_code(referral_code) do
      decrypt_user_name_and_mount_response(customers, referral_code)
    else
      :pending -> {:error, :account_must_be_complete}
    end
  end

  defp decrypt_user_name_and_mount_response(customers, referral_code) do
    Enum.map(customers, fn customer ->
      decrypt_key =
        UserEncryption.generate_secret_key(customer.id, referral_code, customer.unique_salt)

      name_to_be_shared =
        UserEncryption.decrypt(customer.encrypted_name_to_be_shared, decrypt_key)

      %{customer_id: customer.id, customer_name: name_to_be_shared}
    end)
  end
end
