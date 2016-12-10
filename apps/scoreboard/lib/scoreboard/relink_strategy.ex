defmodule Scoreboard.RelinkStategy do
  @moduledoc """
  Strategy to refresh the keys in a scoreboard from a common source of truth
  in the event of a netsplit and subsequent relink.
  """

  @doc """
  Takes an existing key-value pair and updates the value.
  """
  @callback refresh_key({key :: Scoreboard.key, old_value :: integer}) :: {Scoreboard.key, integer}


  @doc """
  Takes a list of existing key-value pairs and updates their values.

  This function is optional and can be used if whatever the source of truth is
  has support for a bulk operation.
  """
  @callback refresh_keys(keys :: [Scoreboard.key]) :: [{Scoreboard.key, integer}]

  @optional_callbacks refresh_keys: 1
end
