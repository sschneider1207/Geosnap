defmodule Geosnap.Db.App do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
    ]

    opts = [strategy: :one_for_one, name: Geosnap.Db.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
