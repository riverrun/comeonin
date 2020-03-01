defmodule Comeonin.Mixfile do
  use Mix.Project

  @version "5.3.1"
  @description "A specification for password hashing libraries"

  def project do
    [
      app: :comeonin,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      name: "Comeonin",
      description: @description,
      package: package(),
      source_url: "https://github.com/riverrun/comeonin",
      deps: deps(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.20", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.3", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "CHANGELOG.md", "README.md", "LICENSE"],
      maintainers: ["David Whitlock"],
      licenses: ["BSD"],
      links: %{"GitHub" => "https://github.com/riverrun/comeonin"}
    ]
  end
end
