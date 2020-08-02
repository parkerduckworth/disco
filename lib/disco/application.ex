defmodule Disco.Application do
  @moduledoc false

  use Application

  import Supervisor.Spec

  def start(_type, _args) do
    children = [
      worker(Disco.Server, [], shutdown: 2000)
    ]
    opts = [strategy: :one_for_all, name: Disco.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
