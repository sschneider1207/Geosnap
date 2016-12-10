defmodule Scoreboard.RelinkStrategy.DbRelinkStrategy do
  @behaviour Scoreboard.RelinkStrategy

  def refresh_key({id, _old_value}) do
    {id, 0}
  end

  def refresh_keys(kvps) do
    ids = Enum.map(kvps, &elem(&1, 0))

    kvps
  end
end
