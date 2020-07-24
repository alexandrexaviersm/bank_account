defmodule BankAccount.AccountOpening do
  @moduledoc """
  Opening a new account
  """
  alias BankAccount.Repo
  alias BankAccount.Schema.{Account, Customer}
  alias BankAccount.UserEncryption.Security.Utils

  def run(customer, account) do
    if all_data_is_properly_filled_before_opening_account?(customer) do
      completes_the_process_of_opening_an_account(account)
    else
      {:ok, account}
    end
  end

  defp all_data_is_properly_filled_before_opening_account?(%Customer{
         city: city,
         country: country,
         encrypted_birth_date: encrypted_birth_date,
         cpf_hash: cpf_hash,
         encrypted_email: encrypted_email,
         encrypted_name: encrypted_name,
         gender: gender,
         referral_code: referral_code,
         state: state
       })
       when is_binary(city) and is_binary(country) and is_binary(encrypted_birth_date) and
              is_binary(cpf_hash) and is_binary(encrypted_email) and is_binary(encrypted_name) and
              is_atom(gender) and is_binary(referral_code) and is_binary(state) do
    true
  end

  defp all_data_is_properly_filled_before_opening_account?(_customer), do: false

  defp completes_the_process_of_opening_an_account(account) do
    attrs = %{
      referral_code_to_be_shared: Utils.generate_referral_code(),
      status: :complete
    }

    Account.update_changeset(account, attrs)
    |> Repo.update()
  end
end
