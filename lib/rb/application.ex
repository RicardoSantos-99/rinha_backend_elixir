defmodule Rb.Application do
  use Application

  @impl true
  def start(_type, _args) do
    connect_to_cluster(:timer.minutes(1))

    children = [
      Rb.Metrics,
      Repo,
      Rb.System,
      {Plug.Cowboy, scheme: :http, plug: Rb.Router, options: [port: get_port()]}
    ]

    opts = [strategy: :one_for_one, name: Rb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp connect_to_cluster(timeout) do
    do_connect_to_cluster(timeout, System.monotonic_time(:second))
  end

  defp do_connect_to_cluster(timeout, start) do
    nodes = System.get_env("PEER_NODES")

    if nodes != nil do
      success =
        nodes
        |> String.split(",")
        |> Enum.reject(&(&1 == ""))
        |> Enum.all?(&Node.connect(String.to_atom(&1)))

      if success do
        :ok
      else
        if System.monotonic_time(:second) - start > timeout do
          raise "TIMEOUT! Could not connect to cluster!"
        else
          Process.sleep(:timer.seconds(1))
          do_connect_to_cluster(timeout, start)
        end
      end
    end
  end

  defp get_port do
    case System.get_env("PORT") do
      nil -> 4000
      port_str -> String.to_integer(port_str)
    end
  end
end
