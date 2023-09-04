defmodule Rb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  IO.inspect("port: #{System.get_env("PORT") || 4000}")

  defp get_port do
    case System.get_env("PORT") do
      nil -> 4000
      port_str -> String.to_integer(port_str)
    end
  end

  @impl true
  def start(_type, _args) do
    children = [
      Rb.System,
      {Plug.Cowboy, scheme: :http, plug: Rb.Router, options: [port: get_port()]}
      # Starts a worker by calling: Rb.Worker.start_link(arg)
      # {Rb.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
