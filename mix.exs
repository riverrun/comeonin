defmodule Comeonin.Mixfile do
  use Mix.Project

  @version "4.1.2"

  @description """
  Password hashing library for Elixir.
  """

  def project do
    [
      app: :comeonin,
      version: @version,
      elixir: "~> 1.4",
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
      {:argon2_elixir, "~> 1.2", optional: true},
      {:bcrypt_elixir, "~> 0.12.1 or ~> 1.0", optional: true},
      {:pbkdf2_elixir, "~> 0.12", optional: true},
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
