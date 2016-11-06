defmodule Geosnap.Encryption do
  @moduledoc """
  General purpose encryption functions for the Geosnap ecosystem.
  """
  @curve Application.get_env(:geosnap_encryption, :curve_name)
  @comeonin_mod Application.get_env(:geosnap_encryption, :comeonin_mod)
  @hash_function Application.get_env(:geosnap_encryption, :hash_function)

  @type key :: {public_key, private_key}
  @type public_key :: String.t
  @type private_key :: String.t

  @doc """
  Generates an ECDH public/private key derived from the specified private key, or from
  none of not given.
  """
  @spec generate_key(nil | private_key) :: key
  def generate_key(priv \\ nil)
  def generate_key(nil) do
    {pub, priv} = :crypto.generate_key(:ecdh, @curve)
    {Base.encode64(pub), Base.encode64(priv)}
  end
  def generate_key(priv) do
    bytes = Base.decode64!(priv)
    {pub, priv} = :crypto.generate_key(:ecdh, @curve, bytes)
    {Base.encode64(pub), Base.encode64(priv)}
  end

  @doc """
  Generates a signature for a message given a private key.
  """
  @spec sign(String.t, private_key) :: String.t
  def sign(msg, priv) do
    bytes = Base.decode64!(priv)
    :crypto.sign(:ecdsa, :sha256, msg, [bytes, @curve])
    |> Base.encode64()
  end

  @doc """
  Verifies a signature for a message given a public key.
  """
  @spec verify_signature(String.t, String.t, public_key) :: boolean
  def verify_signature(msg, sig, pub) do
    key_bytes = Base.decode64!(pub)
    sig_bytes = Base.decode64!(sig)
    :crypto.verify(:ecdsa, :sha256, msg, sig_bytes, [key_bytes, @curve])
  end

  @doc """
  Hashes a password.
  """
  @spec hash_password(String.t) :: String.t
  def hash_password(password) do
    :crypto.hash(@hash_function, password)
    |> @comeonin_mod.hashpwsalt()
  end

  @doc """
  Checks a password against a hash in constant time.
  """
  @spec check_password(String.t, String.t) :: boolean
  def check_password(password, hash) do
    :crypto.hash(@hash_function, password)
    |> @comeonin_mod.checkpw(hash)
  end
end
