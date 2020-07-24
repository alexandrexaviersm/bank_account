defmodule BankAccount.RegisterCustomer do
  @moduledoc """
  Creating a new customer
  """

  alias BankAccount.Repo
  alias BankAccount.UserEncryption.Security.Utils, as: UserEncryption
  alias BankAccount.Schema.Customer
  alias Ecto.Multi

  # Verifica se todos os campos foram preenchidos
  # If true
  # # Atualiza o status da Account e cria um referral_code_to_be_shared
  # # O sistema informa uma mensagem de sucesso, juntamente com o código
  # # de 8 dígitos previamente criado
  # else
  # # O sistema informa uma mensagem de sucesso, retorna os dados fornecidos e o stautus pendent

  ## Event-driven architectures
  # # Publish Event: Customer Created
  # # AccountOpening Subscribe Customer Created

  def run(params) do
    customer =
      Repo.all(Customer)
      |> Enum.find(fn customer ->
        Bcrypt.verify_pass(params[:cpf], customer.cpf_hash)
      end)

    result =
      case customer do
        %Customer{} = customer ->
          update_customer(customer, params)

        nil ->
          create_customer(params)
      end
  end

  defp update_customer(customer, params) do
    Customer.update_changeset(customer, params)
    |> Repo.update()
  end

  defp create_customer(params) do
    attrs = %{id: Ecto.UUID.generate(), unique_salt: UserEncryption.generate_unique_salt()}

    merged_params = Map.merge(params, attrs)

    Multi.new()
    |> Multi.insert(:customer, Customer.create_changeset(merged_params))
    |> Multi.insert(:account, fn %{customer: customer} ->
      Ecto.build_assoc(customer, :account)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{customer: customer, account: account}} ->
        {:ok, {customer, account}}

      {:error, _failed_operation, failed_value, _changes} ->
        {:error, failed_value}
    end
  end
end
