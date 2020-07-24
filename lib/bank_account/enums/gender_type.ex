defmodule BankAccount.Enums.GenderType do
  @moduledoc """
  Enum Gender Type
  """
  use EctoEnum.Postgres, type: :gender, enums: [:woman, :man, :non_binary, :others, :not_identify]

  def values do
    __MODULE__.__enum_map__()
  end
end
