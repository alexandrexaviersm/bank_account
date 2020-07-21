defmodule BankAccount.Account do
  use Ecto.Schema
  import Ecto.Changeset

  alias BankAccount.Customer

  schema "accounts" do
    field :referral_code, :string
    field :status, :string

    timestamps()

    belongs_to :customer, Customer
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:status, :referral_code])
    |> validate_required([:status, :referral_code])
  end
end
