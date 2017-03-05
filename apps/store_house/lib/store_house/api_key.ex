defmodule StoreHouse.ApiKey do
  use StoreHouse.Table, :api_key
  alias StoreHouse.{Application, Utils}
  require Application
  @key_length 128

  @doc """
  Creates a new api key record for an application.
  """
  @spec new(String.t) :: tuple
  def new(app) do
    api_key([
      key: :crypto.strong_rand_bytes(@key_length),
      application_key: Application.application(app, :key),
      inserted_at: Utils.timestamp,
      updated_at: Utils.timestamp
    ])
  end
end
