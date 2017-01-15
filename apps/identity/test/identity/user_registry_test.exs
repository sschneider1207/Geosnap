defmodule Identity.UserRegistryTest do
  use ExUnit.Case
  alias Identity.{User, UserRegistry}

  test "can register and lookup with schema" do
    me = self()
    user = %User{username: "username"}
    {:ok, _} = UserRegistry.register(user)

    assert {^me, ^user} = UserRegistry.lookup(user.username)
  end

  test "can register and lookup with pid" do
    me = self()
    user = %User{username: "username"}
    {:ok, _} = UserRegistry.register(user)

    assert {^me, ^user} = UserRegistry.lookup(me)
  end

  test "can register and use via" do
    me = self()
    user = %User{username: "username"}
    {:ok, _} = UserRegistry.register(user)
    via = UserRegistry.via(user.username)
    name = :gen.name(via)

    assert ^me = Registry.whereis_name(name)
  end

  test "process can update their own schema" do
    me = self()
    user = %User{username: "username"}
    {:ok, _} = UserRegistry.register(user)
    updated_user = %{user| permissions: 42}
    :ok = UserRegistry.update_schema!(updated_user)

    assert {^me, ^updated_user} = UserRegistry.lookup(updated_user.username)
  end
end
