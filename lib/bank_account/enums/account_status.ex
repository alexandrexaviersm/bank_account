defmodule BankAccount.Enums.AccountStatus do
  @moduledoc """
  Enum Account Status
  """
  use EctoEnum.Postgres, type: :account_status, enums: [:pending, :complete]

  def values do
    __MODULE__.__enum_map__()
  end

  def get_from_key(key) do
    Map.get(values(), key)
  end
end
