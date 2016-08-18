defmodule Geosnap.Encryption do
  @moduledoc """
  General purpose encryption functions for the Geosnap ecosystem.
  """
  @curve Application.get_env(:geosnap_encryption, :curve_name)

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
    {pub, priv} = :crypto.generate_key(:ecdh, @curve, priv)
    {Base.encode64(pub), Base.encode64(priv)}
  end

  @doc """
  Hashes a password.
  """
  @spec hash_password(String.t) :: String.t
  defdelegate hash_password(password), to: Comeonin.Pbkdf2, as: :hashpwsalt

  @doc """
  Checks a password against a hash in constant time.
  """
  @spec check_password(String.t, String.t) :: boolean
  defdelegate check_password(password, hash), to: Comeonin.Pbkdf2, as: :checkpw
end
