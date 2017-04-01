defmodule StoreHouse.ApiKey do
  use StoreHouse.Table, :api_key
  alias StoreHouse.Utils
  require Application
  @key_length 128

  @doc """
  Creates a new api key record for an application.
  """
  @spec new(String.t) :: tuple
  def new(app_key) do
    api_key([
      key: :crypto.strong_rand_bytes(@key_length),
      application_key: app_key,
      inserted_at: Utils.timestamp,
      updated_at: Utils.timestamp
    ])
  end
end
