defmodule BankAccount.Schema.Customer do
  @moduledoc """
  Customer schema
  """
  use BankAccount.Schema
  import Ecto.Changeset

  alias BankAccount.CustomerRepo
  alias BankAccount.Enums.Countries
  alias BankAccount.Enums.GenderType
  alias BankAccount.Schema.Account
  alias BankAccount.UserEncryption.Security.Utils, as: UserEncryption
  alias Ecto.Changeset

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

  def create_changeset(%__MODULE__{} = struct \\ %__MODULE__{}, attrs) do
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
    |> validate_inclusion(:gender, GenderType.values() |> Map.keys())
    |> validate_cpf(attrs)
    |> validate_name(attrs)
    |> validate_email(attrs)
    |> validate_existing_refferal_code()
    |> put_cpf(attrs)
    |> put_encrypted_name(attrs)
    |> put_encrypted_birth_date(attrs)
    |> put_encrypted_email(attrs)
    |> put_encrypted_name_to_be_shared(attrs)
  end

  def update_changeset(%__MODULE__{} = struct, attrs) do
    struct
    |> cast(attrs, @input_fields)
    |> validate_length(:city, min: 3, max: 50)
    |> validate_length(:country, is: 2)
    |> validate_length(:state, is: 2)
    |> validate_length(:referral_code, is: 8)
    |> validate_inclusion(
      :country,
      Enum.map(Countries.list_countries(), fn %{code: code} -> code end)
    )
    |> validate_inclusion(:gender, GenderType.values() |> Map.keys())
    |> validate_cpf(attrs)
    |> validate_name(attrs)
    |> validate_email(attrs)
    |> validate_existing_refferal_code()
    |> update_encrypted_name(attrs)
    |> update_encrypted_birth_date(attrs)
    |> update_encrypted_email(attrs)
    |> update_encrypted_name_to_be_shared(attrs)
  end

  def update_encrypted_name_to_be_shared_changeset(%__MODULE__{} = struct, attrs) do
    struct
    |> cast(attrs, [:encrypted_name_to_be_shared])
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

  defp validate_email(%Changeset{} = changeset, %{email: email}) when is_binary(email) do
    case String.match?(
           email,
           ~r/^[\w.!#$%&’*+\-\/=?\^`{|}~]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*$/i
         ) do
      true -> changeset
      false -> add_error(changeset, :email, "is invalid")
    end
  end

  defp validate_email(%Changeset{} = changeset, %{email: _email}) do
    add_error(changeset, :email, "is invalid")
  end

  defp validate_email(%Changeset{} = changeset, _), do: changeset

  defp validate_existing_refferal_code(
         %Changeset{
           valid?: true,
           changes: %{referral_code: referral_code}
         } = changeset
       )
       when is_binary(referral_code) do
    case CustomerRepo.referral_code_exists?(referral_code) do
      true ->
        changeset

      false ->
        add_error(
          changeset,
          :referral_code,
          "you need to provide an existing referral code"
        )
    end
  end

  defp validate_existing_refferal_code(%Changeset{} = changeset), do: changeset

  defp put_encrypted_name(
         %Changeset{valid?: true, changes: %{id: id, unique_salt: salt}} = changeset,
         %{name: name, cpf: cpf}
       )
       when is_binary(name) do
    key = UserEncryption.generate_secret_key(id, cpf, salt)

    put_change(changeset, :encrypted_name, UserEncryption.encrypt(name, key))
  end

  defp put_encrypted_name(%Changeset{} = changeset, _attrs), do: changeset

  defp update_encrypted_name(
         %Changeset{valid?: true, data: %{id: id, unique_salt: salt}} = changeset,
         %{name: name, cpf: cpf}
       )
       when is_binary(name) do
    key = UserEncryption.generate_secret_key(id, cpf, salt)

    changeset = put_change(changeset, :encrypted_name, UserEncryption.encrypt(name, key))

    {:ok, customer} = BankAccount.CustomerRepo.get_customer(id)

    case customer.referral_code do
      nil ->
        changeset

      referral_code ->
        key = UserEncryption.generate_secret_key(id, referral_code, salt)

        put_change(
          changeset,
          :encrypted_name_to_be_shared,
          UserEncryption.encrypt(name, key)
        )
    end
  end

  defp update_encrypted_name(%Changeset{} = changeset, _attrs), do: changeset

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

  defp update_encrypted_birth_date(
         %Changeset{
           valid?: true,
           data: %{id: id, unique_salt: salt}
         } = changeset,
         %{birth_date: birth_date, cpf: cpf}
       )
       when is_binary(birth_date) do
    key = UserEncryption.generate_secret_key(id, cpf, salt)

    put_change(changeset, :encrypted_birth_date, UserEncryption.encrypt(birth_date, key))
  end

  defp update_encrypted_birth_date(%Changeset{} = changeset, _attrs), do: changeset

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

  defp update_encrypted_email(
         %Changeset{valid?: true, data: %{id: id, unique_salt: salt}} = changeset,
         %{email: email, cpf: cpf}
       )
       when is_binary(email) do
    key = UserEncryption.generate_secret_key(id, cpf, salt)

    put_change(changeset, :encrypted_email, UserEncryption.encrypt(email, key))
  end

  defp update_encrypted_email(%Changeset{} = changeset, _attrs), do: changeset

  defp put_encrypted_name_to_be_shared(
         %Changeset{
           valid?: true,
           changes: %{id: id, unique_salt: salt, referral_code: referral_code}
         } = changeset,
         %{name: name}
       )
       when is_binary(name) do
    key = UserEncryption.generate_secret_key(id, referral_code, salt)

    put_change(
      changeset,
      :encrypted_name_to_be_shared,
      UserEncryption.encrypt(name, key)
    )
  end

  defp put_encrypted_name_to_be_shared(%Changeset{} = changeset, _attrs), do: changeset

  defp update_encrypted_name_to_be_shared(
         %Changeset{
           valid?: true,
           data: %{id: id, unique_salt: salt, referral_code: referral_code}
         } = changeset,
         %{name: name}
       )
       when is_binary(referral_code) and is_binary(name) do
    key = UserEncryption.generate_secret_key(id, referral_code, salt)

    put_change(
      changeset,
      :encrypted_name_to_be_shared,
      UserEncryption.encrypt(name, key)
    )
  end

  defp update_encrypted_name_to_be_shared(
         %Changeset{
           valid?: true,
           data: %{id: id, unique_salt: salt, referral_code: referral_code}
         } = changeset,
         %{cpf: cpf}
       )
       when is_binary(referral_code) do
    {:ok, customer} = BankAccount.CustomerRepo.get_customer(id)

    case customer.encrypted_name do
      nil ->
        changeset

      encrypted_name ->
        key = UserEncryption.generate_secret_key(id, cpf, salt)
        name = UserEncryption.decrypt(encrypted_name, key)

        key = UserEncryption.generate_secret_key(id, referral_code, salt)

        put_change(
          changeset,
          :encrypted_name_to_be_shared,
          UserEncryption.encrypt(name, key)
        )
    end
  end

  defp update_encrypted_name_to_be_shared(%Changeset{} = changeset, _attrs), do: changeset
end
