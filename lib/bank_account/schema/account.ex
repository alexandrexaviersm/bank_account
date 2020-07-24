defmodule BankAccount.Schema.Account do
  @moduledoc """
  Account schema
  """
  use BankAccount.Schema
  import Ecto.Changeset

  alias BankAccount.Enums.AccountStatus
  alias BankAccount.Schema.Customer

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
    field :status, AccountStatus, default: :pending

    timestamps()

    belongs_to :customer, Customer
  end

  def update_changeset(%__MODULE__{} = struct, attrs) do
    struct
    |> cast(attrs, [:referral_code_to_be_shared, :status])
    |> validate_required([:referral_code_to_be_shared, :status])
    |> validate_length(:referral_code_to_be_shared, is: 8)
    |> validate_inclusion(:status, AccountStatus.values())
  end
end
