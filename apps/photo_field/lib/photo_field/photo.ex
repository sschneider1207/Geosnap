defmodule PhotoField.Photo do
  @moduledoc """
  A GenServer that represents a unique picture.
  """
  use GenServer
  alias PhotoField.PhotoSupervisor
  alias Geosnap.Db
  alias Db.Picture

  @type upvote :: 1
  @type downvote :: -1
  @type vote :: upvote | downvote

  defmodule State do
    @moduledoc false
    defstruct [
      schema_key: nil,
      score_key: nil,
      picture: nil
    ]
  end

  @doc """
  Start a new photo process with either a map of params
  or the id of an existing picture.
  """
  @spec new(map) :: Supervisor.on_start_child
  def new(params) do
    case Db.new_picture(params) do
      {:ok, picture} -> PhotoSupervisor.spawn_photo(picture)
      {:error, errors} -> {:error, errors}
    end
  end

  @doc """
  Gets the pid of the process presenting the photo with the given id.
  """
  @spec get(integer) :: pid | nil
  def get(id) do
    scope = PhotoField.scope()
    case :gproc.where({:n, scope, id}) do
      :undefined -> new_by_id(id)
      pid -> pid
    end
  end

  defp new_by_id(id) do
    Db.get_picture(id, true)
    |> safe_new()
  end

  defp safe_new(nil) do
    nil
  end
  defp safe_new(picture) do
    case PhotoSupervisor.spawn_photo(picture) do
      {:error, {:duplicate, pid}} -> pid
      {:error, :expired} -> nil
      {:ok, pid} -> pid
    end
  end

  @doc """
  Gets a photo schema struct based on a pid.
  """
  @spec get_schema(pid) :: Picture.t
  def get_schema(pid) do
    scope = PhotoField.scope()
    :gproc.get_value({:p, scope, :schema}, pid)
  end

  @doc """
  Gets the current popularity score of a picture based on a pid.
  """
  @spec get_score(pid) :: integer
  def get_score(pid) do
    scope = PhotoField.scope()
    :gproc.get_value({:c, scope, :score}, pid)
  end

  @doc """
  Registers a vote for a picture for a specific user.
  """
  @spec vote_on(pid, integer, vote) :: {:ok, PictureVote.t} | {:error, map}
  def vote_on(pid, user_id, value) when value in -1..1 do
    GenServer.call(pid, {:new_vote, user_id, value})
  end

  @doc """
  Updates an existing vote on a picture.
  """
  @spec update_vote_on(pid, PictureVote.t, vote) :: {:ok, PictureVote.t} | {:error, map}
  def update_vote_on(pid, old_vote, value) when value in -1..1 do
    GenServer.call(pid, {:update_vote, old_vote, value})
  end

  @doc """
  Deletes a vote on a picture.
  """
  @spec delete_vote_on(pid, PictureVote.t) :: :ok | {:error, map}
  def delete_vote_on(pid, vote) do
    GenServer.call(pid, {:delete_vote, vote})
  end

  @doc false
  @spec start_link(:gproc.scope, Picture.t, GenServer.option) :: GenServer.on_start
  def start_link(scope, picture, opts \\ []) do
    case Timex.before?(picture.expiration, Timex.now()) do
      true -> {:error, :expired}
      false -> GenServer.start_link(__MODULE__, [scope, picture], opts)
    end
  end

  @doc false
  def init([scope, picture]) do
    me = self()
    schema_key = {:p, scope, :schema}
    score_key = {:c, scope, :score}
    case :gproc.reg_or_locate({:n, scope, picture.id}) do
      {^me, _} ->
        :gproc.reg(schema_key, picture)
        :gproc.reg(score_key)
        state = struct(State, [
          schema_key: schema_key,
          score_key: score_key,
          picture: picture])
        init_expiration(state)
        refresh_score(state)
        {:ok, state}
      {pid, _} ->
        {:stop, {:duplicate, pid}}
    end
  end

  @doc false
  def handle_call({:new_vote, user_id, value}, _from, state) do
    params = %{picture_id: state.picture.id, user_id: user_id, value: value}
    case Db.vote_on_picture(params) do
      {:error, errors} ->
        {:reply, {:error, errors}, state}
      {:ok, vote} ->
        :gproc.update_counter(state.score_key, value)
        {:reply, {:ok, vote}, state}
    end
  end
  def handle_call({:update_vote, old_vote, value}, _from, state) do
    case Db.update_vote_on_picture(old_vote, value) do
      {:error, errors} ->
        {:reply, {:error, errors}, state}
      {:ok, vote} ->
        :gproc.update_counter(state.score_key, value + (old_vote.value * -1))
        {:reply, {:ok, vote}, state}
    end
  end
  def handle_call({:delete_vote, vote}, _from, state) do
    case Db.delete_picture_vote(vote) do
      {:error, errors} ->
        {:reply, {:error, errors}, state}
      :ok ->
        :gproc.update_counter(state.score_key, vote.value * -1)
        {:reply, :ok, state}
    end
  end

  @doc false
  def handle_info(:expired, state) do
    :gproc.goodbye() # Bye bye!
    Db.delete_picture(state.picture)
    {:stop, {:shutdown, :expired}, state}
  end

  defp refresh_score(state) do
    votes = Db.get_picture_votes(state.picture.id)
    score = Enum.reduce(votes, 0, fn vote, acc -> acc + vote.value end)
    :gproc.set_value(state.score_key, score)
    :ok
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
