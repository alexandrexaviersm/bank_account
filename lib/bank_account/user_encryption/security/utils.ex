defmodule BankAccount.UserEncryption.Security.Utils do
  @moduledoc """
  Public API functions
  """

  @aad "AES256GCM"

  def generate_unique_salt do
    :crypto.strong_rand_bytes(16)
    |> :base64.encode()
  end

  def generate_secret_key(uuid, cpf, salt) do
    digest_source = cpf <> salt <> uuid

    :crypto.hash(:sha512, digest_source)
    |> :base64.encode()
    |> String.reverse()
    |> String.slice(0, 24)
    |> String.reverse()
  end

  def generate_referral_code do
    :crypto.strong_rand_bytes(16)
    |> :base64.encode()
    |> String.slice(0, 8)
  end

  def encrypt(val, key) do
    iv = :crypto.strong_rand_bytes(16)

    {ciphertext, ciphertag} =
      :crypto.block_encrypt(:aes_gcm, decode_key(key), iv, {@aad, to_string(val), 16})

    (iv <> ciphertag <> ciphertext)
    |> :base64.encode()
  end

  def decrypt(ciphertext, key) do
    ciphertext = :base64.decode(ciphertext)
    <<iv::binary-16, tag::binary-16, ciphertext::binary>> = ciphertext
    :crypto.block_decrypt(:aes_gcm, decode_key(key), iv, {@aad, ciphertext, tag})
  end

  def decode_key(key) do
    :base64.decode(key)
  end
end
