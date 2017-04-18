defmodule StoreHouseTest do
  use ExUnit.Case
  doctest StoreHouse
  
  describe "new_application/1" do

    test "unconfirmed email is aborted" do
      result = StoreHouse.new_application(%{
        "name" => "android",
        "email" => "google@gmail.com",
        "email_confirmation" => "apple@gmail.com"
      })

      assert {:aborted, :emails_do_not_match} = result
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
        "email_confirmation" => "nsa@cia.gov"
      }
      result = StoreHouse.change_application_email(app.key, params)

      assert result === {:aborted, :emails_do_not_match}
    end

    test "missing app key aborts" do
      params = %{
        "email" => "apple@ios.com",
        "email_confirmation" => "apple@ios.com"
      }
      result = StoreHouse.change_application_email("abc", params)

      assert result === {:aborted, :application_not_found}
    end
  
    test "confirmed email changes email", %{app: app} do
      params = %{
          "email" => "apple@ios.com",
          "email_confirmation" => "apple@ios.com"
        }
      {:atomic, new_app} = StoreHouse.change_application_email(app.key, params)

      assert new_app.email === params["email"]
      assert new_app.verified_email === false
    end
  end

  describe "get_application/1" do
    setup do
      {:atomic, {app, key1, key2}} =
        TestUtils.app_params()
        |> StoreHouse.new_application()
      [app: app, key1: key1, key2: key2]
    end

    test "api key retrieves linked app", context do
      {:atomic, app1} = StoreHouse.get_application(context.key1.key)
      {:atomic, app2} = StoreHouse.get_application(context.key2.key)

      assert app1 === context.app
      assert app2 === context.app
    end

    test "fake api key aborts" do
      result = StoreHouse.get_application("abc")

      assert {:aborted, :api_key_not_found} = result
    end
  end

  describe "rotate_api_key/1" do
    setup do
      {:atomic, {app, key1, key2}} =
        TestUtils.app_params()
        |> StoreHouse.new_application()
      [app: app, key1: key1, key2: key2]
    end

    test "rotating key destroys it and returns a new one", context do
      {:atomic, api_key} = StoreHouse.rotate_api_key(context.key1.key)
      bad_result = StoreHouse.get_application(context.key1.key)

      assert {:aborted, :api_key_not_found} = bad_result

      {:atomic, app} = StoreHouse.get_application(api_key.key)
      
      assert app === context.app
    end

    test "rotating fake key aborts" do
      result = StoreHouse.rotate_api_key("abc")

      assert {:aborted, :api_key_not_found} = result
    end
  end
end
