defmodule BankAccount.RegisterCustomer do
  @moduledoc """
  Creating a new customer
  """

  alias BankAccount.AccountOpening
  alias BankAccount.Repo
  alias BankAccount.Schema.Customer
  alias BankAccount.UserEncryption.Security.Utils, as: UserEncryption
  alias Ecto.Multi

  # Verifica se todos os campos foram preenchidos
  # If true
  # # Atualiza o status da Account e cria um referral_code_to_be_shared
  # # O sistema informa uma mensagem de sucesso, juntamente com o código
  # # de 8 dígitos previamente criado
  # else
  # # O sistema informa uma mensagem de sucesso, retorna o stautus pendent

  def run(params) do
    customer =
      Repo.all(Customer)
      |> Enum.find(fn customer ->
        Bcrypt.verify_pass(params[:cpf], customer.cpf_hash)
      end)

    case customer do
      %Customer{} = customer ->
        update_customer(customer, params)

      nil ->
        create_customer(params)
    end
  end

  defp update_customer(customer, params) do
    Multi.new()
    |> Multi.update(:customer, Customer.update_changeset(customer, params))
    |> Multi.run(:account_opening, fn _repo, %{customer: customer} ->
      customer_account = Repo.preload(customer, :account)

      AccountOpening.run(customer, customer_account.account)
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

  defp create_customer(params) do
    attrs = %{id: Ecto.UUID.generate(), unique_salt: UserEncryption.generate_unique_salt()}

    merged_params = Map.merge(params, attrs)

    Multi.new()
    |> Multi.insert(:customer, Customer.create_changeset(merged_params))
    |> Multi.insert(:account, fn %{customer: customer} ->
      Ecto.build_assoc(customer, :account)
    end)
    |> Multi.run(:account_opening, fn _repo, %{customer: customer, account: account} ->
      AccountOpening.run(customer, account)
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
