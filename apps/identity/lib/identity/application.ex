defmodule Identity.Application do
  @moduledoc false
  use Application
  alias Identity.{Repo, UserRegistry, UserSupervisor}

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Repo, []),
      supervisor(UserRegistry, []),
      supervisor(UserSupervisor, []),
    ]

    opts = [strategy: :rest_for_one, name: Identity.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
