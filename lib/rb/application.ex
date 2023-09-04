defmodule Rb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Rb.System,
      {Plug.Cowboy, scheme: :http, plug: Rb.Router, options: [port: 4000]}
      # Starts a worker by calling: Rb.Worker.start_link(arg)
      # {Rb.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
