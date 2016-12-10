defmodule DbRelinkStrategy do
  use Application

  def start(_type, _args) do
    schedulers = System.schedulers_online()
    role = case System.get_env("ROLE") do
      "master" -> {:master, Scoreboard.RelinkStrategy.DbRelinkStrategy}
      "slave" -> :slave
    end
    Scoreboard.start_link(Scoreboard, [partitions: schedulers, role: role])
  end
end
