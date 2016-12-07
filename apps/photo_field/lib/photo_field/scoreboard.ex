defmodule PhotoField.Scoreboard do
  use GenServer
  alias PhotoField.PhotoRegistry
  alias Geosnap.Db
  alias Db.PictureVote

  @type upvote :: 1
  @type downvote :: -1
  @type anti_vote :: 0 # none() is already a time :'(
  @type vote :: upvote | downvote | anti_vote

  @doc """
  Starts a scoreboard process.
  """
  @spec start_link() :: GenServer.on_start
  def start_link() do
    GenServer.start_link(__MODULE__, nil, [name: __MODULE__])
  end

  @doc """
  Gets the score for a picture by id.
  """
  @spec get_score(integer) :: integer
  def get_score(id) do
    case :ets.match_object(__MODULE__, {id, :_}) do
      [] -> 0
      [{^id, score}] -> score
    end
  end

  @doc """
  Forces an update on the score for a given id.
  """
  @spec force_update(integer) :: :ok
  def force_update(id) do
    GenServer.call(__MODULE__, {:force, id})
  end

  @doc """
  Creates a new vote for a user on a picture.
  """
  @spec vote_on(integer, integer, vote) :: {:ok, PictureVote.t} | {:error, map}
  def vote_on(picture_id, user_id, value) when value in -1..1 do
    params = %{picture_id: picture_id, user_id: user_id, value: value}
    case Db.vote_on_picture(params) do
      {:ok, vote} ->
        #try do
          :ets.update_counter(__MODULE__, picture_id, value)
        #rescue
        #  _ -> :ok
        #end
        {:ok, vote}
      {:error, errors} ->
        {:error, errors}
    end
  end

  @doc """
  Updates the value of an existing vote.
  """
  @spec update_vote_on(PictureVote.t, vote) :: {:ok, PictureVote.t} | {:error, map}
  def update_vote_on(%{value: value} = vote, value), do: {:ok, vote}
  def update_vote_on(vote, new_value) when new_value in -1..1 do
    case Db.update_vote_on_picture(vote, new_value) do
      {:ok, new_vote} ->
        try do
          diff = -1 * vote.value + new_value
          :ets.update_counter(__MODULE__, new_vote.picture_id, diff)
        rescue
          _ -> :ok
        end
        {:ok, new_vote}
      {:error, errors} ->
        {:error, errors}
    end
  end

  @doc """
  Deletes a vote on a picture.
  """
  @spec delete_vote(PictureVote.t) :: :ok | {:error, map}
  def delete_vote(vote) do
    case Db.delete_picture_vote(vote) do
      :ok ->
        try do
          :ets.update_counter(__MODULE__, vote.picture_id, -1 * vote.value)
        rescue
          _ -> :ok
        end
        :ok
      {:error, errors} ->
        {:error, errors}
    end
  end

  @doc """
  Gets a vote for a picture by the id of the picture of user who voted.
  """
  @spec get_vote(integer, integer) :: PictureVote.t | nil
  defdelegate get_vote(user_id, picture_id), to: Db, as: :get_picture_vote

  @doc false
  def init(nil) do
    tab = :ets.new(__MODULE__, [:public, :named_table, {:write_concurrency, true}, {:read_concurrency, true}])
    {:ok, tab}
  end

  @doc false
  def handle_call({:force, id}, _from, state) do
    score = get_repo_score(id)
    :ets.insert(state, {id, score})
    {:reply, :ok, state}
  end

  @doc false
  def handle_info({:register, PhotoRegistry, id, _pid, _picture}, state) do
    score = get_repo_score(id)
    :ets.insert_new(state, {id, score})
    {:noreply, state}
  end
  def handle_info({:unregister, PhotoRegistry, id, _picture}, state) do
    :ets.delete(state, id)
    {:noreply, state}
  end
  def handle_info(_, state) do
    {:noreply, state}
  end

  defp get_repo_score(id) do
    votes = Db.get_picture_votes(id)
    Enum.reduce(votes, 0, fn vote, acc -> acc + vote.value end)
  end
end
