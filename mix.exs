defmodule Sabotnik.Mixfile do
  use Mix.Project

  def project do
    [app: :sabotnik,
     version: "0.0.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :slack, :httpoison]]
  end

  defp deps do
    [{:slack, "~> 0.2.0"},
     {:websocket_client, git: "https://github.com/jeremyong/websocket_client"},
     {:httpoison, "~> 0.7.2"},
     {:poison, "~> 1.5.0"}]
  end
end
