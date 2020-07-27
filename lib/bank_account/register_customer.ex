defmodule BankAccount.RegisterCustomer do
  @moduledoc """
  Creating a new customer
  """

  alias BankAccount.AccountOpening
  alias BankAccount.CustomerRepo
  alias BankAccount.Repo
  alias BankAccount.Schema.{Account, Customer}
  alias BankAccount.UserEncryption.Security.Utils, as: UserEncryption
  alias Ecto.Multi

  def run(params) do
    case CustomerRepo.find_customer_by_cpf(params[:cpf]) do
      %Customer{} = customer ->
        update_customer(customer, params)

      nil ->
        create_customer(params)
    end
  end

  defp update_customer(customer, params) do
    %{account: %Account{} = account} = BankAccount.Repo.preload(customer, :account)

    case account.status == :complete do
      true ->
        {:ok, {:account_already_complete, account, customer}}

      false ->
        Multi.new()
        |> Multi.update(:customer, Customer.update_changeset(customer, params))
        |> Multi.run(:account_opening, fn _repo, %{customer: customer} ->
          AccountOpening.run(customer)
        end)
        |> Repo.transaction()
        |> case do
          {:ok,
           %{
             customer: customer,
             account_opening: account
           }} ->
            {:ok, {customer, account}}

          {:error, _failed_operation, failed_value, _changes} ->
            {:error, failed_value}
        end
    end
  end

  defp create_customer(params) do
    attrs = %{id: Ecto.UUID.generate(), unique_salt: UserEncryption.generate_unique_salt()}

    merged_params = Map.merge(params, attrs)

    Multi.new()
    |> Multi.insert(:customer, Customer.create_changeset(merged_params))
    |> Multi.insert(:account, fn %{customer: customer} ->
      Ecto.build_assoc(customer, :account)
    end)
    |> Multi.run(:account_opening, fn _repo, %{customer: customer} ->
      AccountOpening.run(customer)
    end)
    |> Repo.transaction()
    |> case do
      {:ok,
       %{
         customer: customer,
         account_opening: account
       }} ->
        {:ok, {customer, account}}

      {:error, _failed_operation, failed_value, _changes} ->
        {:error, failed_value}
    end
  end
end
