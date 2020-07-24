defmodule BankAccount.Customer do
  @moduledoc """
  Customer schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias BankAccount.Account
  alias BankAccount.Enums.GenderType
  alias BankAccount.Lists.Countries
  alias BankAccount.UserEncryption.Security.Utils, as: UserEncryption
  alias Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  @type t :: %__MODULE__{
          id: :uuid,
          city: String.t(),
          country: String.t(),
          encrypted_birth_date: String.t(),
          cpf_hash: String.t(),
          encrypted_email: String.t(),
          encrypted_name: String.t(),
          encrypted_name_to_be_shared: String.t(),
          gender: GenderType.t(),
          referral_code: String.t(),
          state: String.t(),
          unique_salt: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "customers" do
    field :city, :string
    field :country, :string
    field :cpf_hash, :string
    field :encrypted_birth_date, :string
    field :encrypted_email, :string
    field :encrypted_name, :string
    field :encrypted_name_to_be_shared, :string
    field :gender, GenderType
    field :referral_code, :string
    field :state, :string
    field :unique_salt, :string

    timestamps()

    has_one :account, Account
  end

  @input_fields ~w(id city country gender referral_code state unique_salt)a

  def create_changeset(%__MODULE__{} = struct, attrs) do
    struct
    |> cast(attrs, @input_fields)
    |> validate_required([:id, :unique_salt])
    |> validate_length(:city, min: 3, max: 50)
    |> validate_length(:country, is: 2)
    |> validate_length(:state, is: 2)
    |> validate_length(:referral_code, is: 8)
    |> validate_inclusion(
      :country,
      Enum.map(Countries.list_countries(), fn %{code: code} -> code end)
    )
    |> validate_inclusion(:gender, GenderType.values())
    |> validate_cpf(attrs)
    |> validate_name(attrs)
    |> put_cpf(attrs)
    |> put_encrypted_name(attrs)
    |> put_encrypted_birth_date(attrs)
    |> put_encrypted_email(attrs)
  end

  defp validate_cpf(%Changeset{} = changeset, %{cpf: cpf}) when is_atom(cpf) do
    add_error(changeset, :cpf, "is invalid")
  end

  defp validate_cpf(%Changeset{} = changeset, %{cpf: cpf}) do
    case CPF.valid?(cpf) do
      true -> changeset
      false -> add_error(changeset, :cpf, "is invalid")
    end
  end

  defp validate_cpf(%Changeset{} = changeset, _attrs) do
    add_error(changeset, :cpf, "can't be blank")
  end

  defp validate_name(%Changeset{} = changeset, %{name: name}) when is_binary(name) do
    cond do
      byte_size(name) < 3 -> add_error(changeset, :name, "should be at least 3 character(s)")
      byte_size(name) > 100 -> add_error(changeset, :name, "should be at most 100 character(s)")
      name -> changeset
    end
  end

  defp validate_name(%Changeset{} = changeset, %{name: _name}) do
    add_error(changeset, :name, "is invalid")
  end

  defp validate_name(%Changeset{} = changeset, _), do: changeset

  defp put_encrypted_name(
         %Changeset{valid?: true, changes: %{id: id, unique_salt: salt}} = changeset,
         %{name: name, cpf: cpf}
       )
       when is_binary(name) do
    key = UserEncryption.generate_secret_key(id, cpf, salt)

    put_change(changeset, :encrypted_name, UserEncryption.encrypt(name, key))
  end

  defp put_encrypted_name(%Changeset{} = changeset, _attrs), do: changeset

  defp put_encrypted_birth_date(
         %Changeset{
           valid?: true,
           changes: %{id: id, unique_salt: salt}
         } = changeset,
         %{birth_date: birth_date, cpf: cpf}
       )
       when is_binary(birth_date) do
    key = UserEncryption.generate_secret_key(id, cpf, salt)

    put_change(changeset, :encrypted_birth_date, UserEncryption.encrypt(birth_date, key))
  end

  defp put_encrypted_birth_date(%Changeset{} = changeset, _attrs), do: changeset

  defp put_cpf(
         %Changeset{valid?: true} = changeset,
         %{cpf: cpf}
       )
       when is_binary(cpf) do
    put_change(changeset, :cpf_hash, Bcrypt.hash_pwd_salt(cpf))
  end

  defp put_cpf(%Changeset{} = changeset, _attrs), do: changeset

  defp put_encrypted_email(
         %Changeset{valid?: true, changes: %{id: id, unique_salt: salt}} = changeset,
         %{email: email, cpf: cpf}
       )
       when is_binary(email) do
    key = UserEncryption.generate_secret_key(id, cpf, salt)

    put_change(changeset, :encrypted_email, UserEncryption.encrypt(email, key))
  end

  defp put_encrypted_email(%Changeset{} = changeset, _attrs), do: changeset
end
