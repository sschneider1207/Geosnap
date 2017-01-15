defmodule Identity.UserSupervisorTest do
  use ExUnit.Case
  alias Identity.{User, UserSupervisor, UserRegistry, Repo}

  test "can start a registered process with a user struct" do
    user = %User{username: "username"}
    {:ok, pid} = UserSupervisor.start_child(user)

    assert {^pid, ^user} = UserRegistry.lookup(user.username)
  end

  test "can start a registered process with a set of params" do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Identity.Repo, {:shared, self()})
    params = %{username: "user", password: "password123", email: "email@nsa.gov"}
    {:ok, pid} = UserSupervisor.start_child(params)

    assert {^pid, _user} = UserRegistry.lookup(pid)
  end

  test "can't start with invalid parmas" do
    assert {:error, _} = UserSupervisor.start_child(%{})
  end
end
