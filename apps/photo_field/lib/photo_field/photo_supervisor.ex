alias Experimental.DynamicSupervisor

defmodule PhotoField.PhotoSupervisor do
  @moduledoc false
  use DynamicSupervisor
  alias Geosnap.Db.Picture

  @spec start_link(DyanmicSupervisor.options) :: Supervisor.on_start
  def start_link(opts \\ []) do
    opts = Keyword.merge(opts, [name: __MODULE__])
    DynamicSupervisor.start_link(__MODULE__, nil, opts)
  end

  @spec spawn_photo(Picture.t) :: Supervisor.on_start_child
  def spawn_photo(picture) do
    DynamicSupervisor.start_child(__MODULE__, [picture])
  end

  def init(nil) do
    children = [
      worker(PhotoField.Photo, [], restart: :transient)
    ]

    {:ok, children, strategy: :one_for_one}
  end
end
