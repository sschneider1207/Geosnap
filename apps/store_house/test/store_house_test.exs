defmodule StoreHouseTest do
  use ExUnit.Case
  doctest StoreHouse
  
  describe "new_application/1" do

    test "unconfirmed email is aborted" do
      result = StoreHouse.new_application(%{
        "name" => "android",
        "email" => "google@gmail.com",
        "confirmed_email" => "apple@gmail.com"
      })

      assert result = {:aborted, :emails_do_not_match}
    end

    test "confirmed email and unique name is inserted" do
      {:atomic, {app, key1, key2}} = 
        TestUtils.app_params()
        |>StoreHouse.new_application()

      assert key1.application_key === app.key
      assert key2.application_key === app.key
    end

    test "non-unique name is aborted" do
      params = TestUtils.app_params()
      {:atomic, _} = StoreHouse.new_application(params)
      result = StoreHouse.new_application(params)

      assert result === {:aborted, :name_not_unique}
    end
  end

  describe "change_application_email/2" do
    
    setup do
      {:atomic, {app, key1, key2}} =
        TestUtils.app_params()
        |> StoreHouse.new_application()
      [app: app, key1: key1, key2: key2]
    end

    test "unconfirmed email is aborted", %{app: app} do
      params = %{
        "email" => "apple@ios.com",
        "confirmed_email" => "nsa@cia.gov"
      }
      result = StoreHouse.change_application_email(app.key, params)

      assert result === {:aborted, :emails_do_not_match}
    end
  end
end
