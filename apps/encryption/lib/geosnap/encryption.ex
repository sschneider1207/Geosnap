defmodule Geosnap.Encryption do
  @curve Application.get_env(:geosnap_encryption, :curve_name)

  def generate_key do
    {pub, priv} = :crypto.generate_key(:ecdh, @curve)
    {Base.encode64(pub), Base.encode64(priv)}
  end

  def generate_key(priv) do
    {pub, priv} = :crypto.generate_key(:ecdh, @curve, priv)
    {Base.encode64(pub), Base.encode64(priv)}
  end
end
