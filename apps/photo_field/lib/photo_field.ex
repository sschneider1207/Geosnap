defmodule PhotoField do
  @moduledoc false
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    scope = Application.get_env(:photo_field, :gproc_scope)
    :ets.new(PhotoField, [:named_table, :protected, {:read_concurrency, true}])
    :ets.insert(PhotoField, {scope})
    children = [
      supervisor(PhotoField.PhotoSupervisor, [scope, [name: PhotoSupervisor]])
    ]

    opts = [strategy: :one_for_one, name: PhotoField.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def scope do
    :ets.first(PhotoField)
  end
end
