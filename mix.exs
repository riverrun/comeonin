defmodule Comeonin.Mixfile do
  use Mix.Project

  @version "3.2.0"

  @description """
  Password hashing (bcrypt, pbkdf2_sha512) library for Elixir.
  """

  def project do
    [app: :comeonin,
     version: @version,
     elixir: "~> 1.2",
     name: "Comeonin",
     description: @description,
     package: package(),
     source_url: "https://github.com/riverrun/comeonin",
     compilers: [:elixir_make] ++ Mix.compilers,
     deps: deps(),
     dialyzer: [plt_file: ".dialyzer/local.plt", remove_defaults: [:unknown]]]
  end

  def application do
    [applications: [:crypto, :logger]]
  end

  defp deps do
    [{:elixir_make, "~> 0.4", runtime: false},
     {:earmark, "~> 1.2", only: :dev},
     {:ex_doc,  "~> 0.16", only: :dev},
     {:dialyxir, "~> 0.5", only: [:dev], runtime: false}]
  end

  defp package do
    [files: ["lib", "c_src", "mix.exs", "Makefile*", "README.md", "LICENSE"],
     maintainers: ["David Whitlock"],
     licenses: ["BSD"],
     links: %{"GitHub" => "https://github.com/riverrun/comeonin",
       "Docs" => "http://hexdocs.pm/comeonin"}]
  end
end
