defmodule Scoreboard.TestApp do
  use Application

  def start(_type, _args) do
    Scoreboard.start_link(Scoreboard, [partitions: 4])
  end
end
