defmodule StoreHouse.App do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: StoreHouse.Worker.start_link(arg1, arg2, arg3)
      # worker(StoreHouse.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: StoreHouse.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp wait_for_tables do
    table_defs = Application.get_env(:store_house, :table_definitions, [])
    tables = for {t, _} <- table_defs, do: t
    :mnesia.wait_for_tables(tables, 20_000)
  end
end
