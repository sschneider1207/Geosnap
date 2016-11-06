defmodule Geosnap.EncryptionTest do
  use ExUnit.Case
  doctest Geosnap.Encryption

  test "keys can be regenerated" do
    {pub, priv} = Geosnap.Encryption.generate_key()
    {pub2, priv2} = Geosnap.Encryption.generate_key(priv)

    assert pub == pub2
    assert priv == priv2
  end

  test "can sign and verify okay" do
    msg = "this is a message"
    {pub, priv} = Geosnap.Encryption.generate_key()
    sig = Geosnap.Encryption.sign(msg, priv)
    assert Geosnap.Encryption.verify_signature(msg, sig, pub) == true
  end

  test "verify with bad signature fails" do
    {pub, priv} = Geosnap.Encryption.generate_key()
    sig = Geosnap.Encryption.sign("msg", priv)
    assert Geosnap.Encryption.verify_signature("other msg", sig, pub) == false
  end

  test "verify with wrong public key fails" do
    msg = "this is a message"
    {_pub, priv} = Geosnap.Encryption.generate_key()
    {pub, _priv} = Geosnap.Encryption.generate_key()
    sig = Geosnap.Encryption.sign(msg, priv)
    assert Geosnap.Encryption.verify_signature(msg, sig, pub) == false
  end

  test "matching passwords return true" do
    hash = Geosnap.Encryption.hash_password("password")
    assert Geosnap.Encryption.check_password("password",hash) == true
  end

  test "different passwords return false" do
    hash = Geosnap.Encryption.hash_password("password1")
    assert Geosnap.Encryption.check_password("password2",hash) == false
  end
end
