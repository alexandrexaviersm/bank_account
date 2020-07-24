defmodule BankAccount.Account do
  @moduledoc """
  Account schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias BankAccount.Customer
  alias BankAccount.Enums.AccountStatus

  @type t :: %__MODULE__{
          id: :uuid,
          customer_id: :uuid,
          referral_code_to_be_shared: String.t(),
          status: AccountStatus.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "accounts" do
    field :referral_code_to_be_shared, :string
    field :status, AccountStatus

    timestamps()

    belongs_to :customer, Customer
  end

  def changeset(%__MODULE__{} = struct, attrs) do
    struct
    |> cast(attrs, [:status])
    |> validate_required([:status])
  end
end
