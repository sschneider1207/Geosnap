defmodule TestUtils do
  alias StoreHouse.{Picture, Category, User, Application}

  def user do
    require User
    {:ok, user} = User.new("user", "password123", "email@nsa.gov")
    key = User.user(user, :key)
    {user, key}
  end

  def category do
    require Category
    cat = Category.new(:nature, "green")
    key = Category.category(cat, :key)
    {cat, key}
  end

  def application do
    require Application
    {:ok, app} = Application.new("name", "cia@kgb.ru")
    key = Application.application(app, :key)
    {app, key}
  end

  def app_params do
    %{
      "name" => UUID.uuid4(:hex),
      "email" => "google@gmail.com",
      "confirmed_email" => "google@gmail.com"
    }
  end

  def picture(uk, ck, ak) do
    require Picture
    {:ok, pic} = Picture.new("title", {0, 0}, "abc", uk, ck, ak)
    key = Picture.picture(pic, :key)
    {pic, key}
  end
end

alias StoreHouse.CLI
CLI.create_schema()
:mnesia.start()
CLI.init()
System.at_exit fn _ ->
  :mnesia.stop()
  CLI.delete_schema()
end

ExUnit.start()
