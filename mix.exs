defmodule Rb.MixProject do
  use Mix.Project

  def project do
    [
      app: :rb,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Rb.Application, []}
    ]
  end

  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.4"},
      {:postgrex, "~> 0.17.3"},
      {:uuid, "~> 1.1"}
    ]
  end
end
