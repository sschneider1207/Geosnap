defmodule PhotoField.Photo do
  @moduledoc """
  A GenServer that represents a picture.
  """
  use GenServer
  alias PhotoField.{PhotoSupervisor, PhotoRegistry}
  alias Geosnap.Db
  alias Db.Picture

  defmodule State do
    @moduledoc false
    defstruct [
      schema_key: nil,
      score_key: nil,
      picture: nil
    ]
  end

  @doc false
  @spec start_link(Picture.t, GenServer.option) :: GenServer.on_start
  def start_link(picture, opts \\ []) do
    case Timex.before?(picture.expiration, Timex.now()) do
      true -> {:error, :expired}
      false -> GenServer.start_link(__MODULE__, [picture], opts)
    end
  end

  @doc false
  def init([picture]) do
    me = self()
    case PhotoRegistry.register(picture) do
      {:ok, _owner} ->
        state = struct(State, [picture: picture])
        init_expiration(state)
        {:ok, state}
      {:error, {:already_registered, pid}} ->
        {:stop, {:duplicate, pid}}
      e ->
        IO.inspect e
        {:stop, e}
    end
  end

  @doc false
  def handle_info(:expired, state) do
    PhotoRegistry.unregister(state.picture)
    Db.delete_picture(state.picture)
    {:stop, {:shutdown, :expired}, state}
  end

  defp init_expiration(state) do
    Timex.diff(state.picture.expiration, Timex.now(), :duration)
    |> Timex.Duration.to_milliseconds()
    |> Kernel.round()
    |> schedule_expiration()
    :ok
  end

  defp schedule_expiration(expiration) when expiration <= 0 do
    send(self(), :expired)
  end
  defp schedule_expiration(expiration) do
    Process.send_after(self(), :expired, expiration)
  end
end
