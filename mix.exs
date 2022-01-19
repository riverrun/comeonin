defmodule Comeonin.Mixfile do
  use Mix.Project

  @version "5.3.3"
  @description "A specification for password hashing libraries"
  @source_url "https://github.com/riverrun/comeonin"

  def project do
    [
      app: :comeonin,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      name: "Comeonin",
      description: @description,
      package: package(),
      deps: deps(),
      docs: docs(),
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
      {:ex_doc, "~> 0.23", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "CHANGELOG.md", "README.md", "LICENSE"],
      maintainers: ["David Whitlock"],
      licenses: ["BSD-3-Clause"],
      links: %{
        "Changelog" => "#{@source_url}/blob/master/CHANGELOG.md",
        "GitHub" => @source_url
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: ["README.md", "UPGRADE_v5.md", "CHANGELOG.md"]
    ]
  end
end
