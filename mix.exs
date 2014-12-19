defmodule Comeonin.Mixfile do
  use Mix.Project

  def project do
    [app: :comeonin,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  def application do
    [applications: [:logger, :bcrypt]]
  end

  defp deps do
    [
      {:bcrypt, github: "opscode/erlang-bcrypt"}
    ]
  end
end
