#Это точка входа в приложение.
defmodule KVstore do
  use Application

  def start(_type, _args) do

    Supervisor.start_link(children(), opts())
  end

  defp children do
    [
      Supervisor.Spec.worker(KVstore.KVStorage, []),
      Plug.Adapters.Cowboy.child_spec(:http, KVstore.KVRouter, [], [port: 8080])
    ]
  end

  defp opts do
    [
      strategy: :one_for_one, name: KVstore.Supervisor
    ]
  end

end
