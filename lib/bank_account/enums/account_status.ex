defmodule BankAccount.Enums.AccountStatus do
  @moduledoc """
  Enum Account Status
  """
  use EctoEnum.Postgres, type: :account_status, enums: [:pending, :complete]

  def values do
    __MODULE__.__enum_map__()
    |> Enum.reduce(%{}, fn value, acc -> Map.put(acc, value, Atom.to_string(value)) end)
  end

  def get_from_key(key) do
    Map.get(values(), key)
  end
end
