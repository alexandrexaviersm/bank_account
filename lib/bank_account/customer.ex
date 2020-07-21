defmodule BankAccount.Customer do
  @moduledoc """
  Customer schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias BankAccount.Account

  schema "customers" do
    field :birth_date, :date
    field :city, :string
    field :country, :string
    field :cpf, :string
    field :email, :string
    field :gender, :string
    field :name, :string
    field :referral_code, :string
    field :state, :string

    timestamps()

    has_one :account, Account
  end

  @doc false
  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [
      :name,
      :email,
      :cpf,
      :birth_date,
      :gender,
      :city,
      :state,
      :country,
      :referral_code
    ])
    |> validate_required([
      :name,
      :email,
      :cpf,
      :birth_date,
      :gender,
      :city,
      :state,
      :country,
      :referral_code
    ])
  end
end
