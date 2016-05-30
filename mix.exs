defmodule Comeonin.Mixfile do
  use Mix.Project

  @version "2.5.0"

  @description """
  Password hashing (bcrypt, pbkdf2_sha512) library for Elixir.
  """

  def project do
    [
      app: :comeonin,
      version: @version,
      elixir: "~> 1.2",
      name: "Comeonin",
      description: @description,
      package: package,
      source_url: "https://github.com/elixircnx/comeonin",
      compilers: [:elixir_make] ++ Mix.compilers,
      deps: deps
    ]
  end

  def application do
    [applications: [:crypto, :logger]]
  end

  defp deps do
    [
      {:elixir_make, git: "https://github.com/elixir-lang/elixir_make.git"},
      {:earmark, "~> 0.2", only: :dev},
      {:ex_doc,  "~> 0.11", only: :dev}
    ]
  end

  defp package do
    [
      files: ["lib", "c_src", "mix.exs", "Makefile*", "README.md", "LICENSE"],
      maintainers: ["David Whitlock"],
      licenses: ["BSD"],
      links: %{"GitHub" => "https://github.com/elixircnx/comeonin",
       "Docs" => "http://hexdocs.pm/comeonin"}
   ]
  end
end
