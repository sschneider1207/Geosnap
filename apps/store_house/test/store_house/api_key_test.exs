defmodule StoreHouse.ApiKeyTest do
  use ExUnit.Case
  alias StoreHouse.{Application, ApiKey, Utils}
  require Application
  require ApiKey

  test "new keys contain their owner application's key" do
    {:ok, app} = Application.new("name", "email@nsa.gov")
    api_key = ApiKey.new(app)

    assert ApiKey.api_key(api_key, :application_key) ===
           Application.application(app, :key)
  end
end
