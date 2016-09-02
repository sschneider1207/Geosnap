alias Experimental.DynamicSupervisor

defmodule PhotoField.PhotoSupervisor do
  @moduledoc false
  use DynamicSupervisor
  alias Geosnap.Db.Picture

  @spec start_link(:gproc.scope, DyanmicSupervisor.options) :: Supervisor.on_start
  def start_link(scope, opts \\ []) do
    opts = Keyword.merge(opts, [name: __MODULE__])
    DynamicSupervisor.start_link(__MODULE__, scope, opts)
  end

  @spec spawn_photo(Picture.t) :: Supervisor.on_start_child
  def spawn_photo(picture) do
    DynamicSupervisor.start_child(__MODULE__, [picture])
  end

  def init(scope) do
    children = [
      worker(PhotoField.Photo, [scope], restart: :transient)
    ]

    {:ok, children, strategy: :one_for_one}
  end
end
