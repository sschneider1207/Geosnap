defmodule Geosnap.Encryption do
  @curve Application.get_env(:geosnap_encryption, :curve_name)
  @private_key Application.get_env(:geosnap_encryption, :private_key)

  @type key :: {public_key, private_key}
  @type public_key :: String.t
  @type private_key :: String.t
  
  @doc """
  Generates an ECDH public/private key derived from the applications set private key.
  """
  @spec generate_key() :: key
  def generate_key do
    generate_key(@private_key)
  end

  @doc """
  Generates an ECDH public/private key derived from the specified private key, or from
  none of not given.
  """
  @spec generate_key(nil | private_key) :: key
  def generate_key(nil) do
    {pub, priv} = :crypto.generate_key(:ecdh, @curve)
    {Base.encode64(pub), Base.encode64(priv)}
  end
  def generate_key(priv) do
    {pub, priv} = :crypto.generate_key(:ecdh, @curve, priv)
    {Base.encode64(pub), Base.encode64(priv)}
  end
end
