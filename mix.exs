defmodule Comeonin.Mixfile do
  use Mix.Project

  @version "5.1.0"
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
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["David Whitlock"],
      licenses: ["BSD"],
      links: %{"GitHub" => "https://github.com/riverrun/comeonin"}
    ]
  end
end
