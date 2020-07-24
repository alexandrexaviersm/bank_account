defmodule BankAccount.Enums.AccountStatus do
  @moduledoc """
  Enum Account Status
  """
  use EctoEnum.Postgres, type: :account_status, enums: [:pending, :complete]
end
