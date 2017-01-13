defmodule Identity.Application do
  @moduledoc false
  use Application
  alias Identity.{Repo, UserRegistry, UserSupervisor}
  
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Identity.Repo, []),
      supervisor(Identity.UserRegistry, []),
      supervisor(Identity.UserSupervisor, []),
    ]

    opts = [strategy: :rest_for_one, name: Identity.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
