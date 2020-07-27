defmodule BankAccount.Factory do
  @moduledoc """
    Simple Factory inspired by https://github.com/thoughtbot/ex_machina
  """

  alias BankAccount.Factories
  alias BankAccount.Repo

  def build(factory_name, attrs \\ [])

  def build(factory_name, attrs) when is_map(attrs) do
    attrs = convert_map_to_keyword(attrs)
    build(factory_name, attrs)
  end

  def build(factory_name, attrs) do
    apply(Factories, factory_name, [attrs])
  end

  @spec insert!(struct()) :: Ecto.Schema.t()
  def insert!(%_{} = factory), do: Repo.insert!(factory)

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end

  defp convert_map_to_keyword(map) do
    Enum.map(map, fn {k, v} ->
      v =
        if is_map(v) do
          convert_map_to_keyword(v)
        else
          v
        end

      {String.to_atom("#{k}"), v}
    end)
  end
end
