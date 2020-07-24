defmodule BankAccount.CreateCustomer do
  @moduledoc """
  Creating a new customer
  """

  alias BankAccount.{Customer, Repo}
  alias BankAccount.UserEncryption.Security.Utils, as: UserEncryption

  # verifica se já existe registro com o CPF informado
  # If true
  # # Atualiza o registro com as novas informações
  # else
  # # Cria um novo Customer
  # # Cria um nova Nova Account com status pendent

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
    Repo.all(Customer)
    |> Enum.find(fn customer ->
      Bcrypt.verify_pass(params[:cpf], customer.cpf_hash)
    end)
    |> case do
      %Customer{} = _customer ->
        {:error, :cpf_already_exists}

      nil ->
        attrs = %{id: Ecto.UUID.generate(), unique_salt: UserEncryption.generate_unique_salt()}

        merged_params = Map.merge(params, attrs)

        %Customer{}
        |> Customer.create_changeset(merged_params)
        |> Repo.insert()
    end
  end
end
