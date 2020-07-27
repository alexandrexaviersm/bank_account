defmodule BankAccount.Enums.GenderType do
  @moduledoc """
  Enum Gender Type
  """
  use EctoEnum.Postgres, type: :gender, enums: [:woman, :man, :non_binary, :others, :not_identify]

  def values do
    __MODULE__.__enum_map__()
    |> Enum.reduce(%{}, fn value, acc -> Map.put(acc, value, Atom.to_string(value)) end)
  end

  def get_from_key(key) do
    Map.get(values(), key)
  end
end
