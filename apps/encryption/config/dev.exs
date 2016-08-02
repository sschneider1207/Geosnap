use Mix.Config

config :geosnap_encryption,
  public_key: File.read!("priv/dev.pub"),
  private_key: File.read!("priv/dev")
