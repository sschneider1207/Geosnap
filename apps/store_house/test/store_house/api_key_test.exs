defmodule StoreHouse.ApiKeyTest do
  use ExUnit.Case
  alias StoreHouse.{Application, ApiKey, Utils}
  require Application
  require ApiKey

  test "new keys contain their owner application's key" do
    now = Utils.timestamp()
    {:ok, app} = Application.new("name", "email@nsa.gov")
    api_key = ApiKey.new(app)

    assert ApiKey.api_key(api_key, :key) !== :undefined
    assert ApiKey.api_key(api_key, :application_key) ===
           Application.application(app, :key)
    assert ApiKey.api_key(api_key, :inserted_at) > now
    assert ApiKey.api_key(api_key, :updated_at) > now
  end
end
