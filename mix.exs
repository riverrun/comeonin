defmodule Mix.Tasks.Compile.Comeonin do
  @shortdoc "Compiles Comeonin"
  def run(_) do
    if Mix.shell.cmd("make priv/bcrypt_nif.so") != 0 do
      raise Mix.Error, message: "could not run `make priv/bcrypt_nif.so`."
    end
  end
end

defmodule Comeonin.Mixfile do
  use Mix.Project

  @description """
  Authentication tool -- supports Bcrypt.
  """

  def project do
    [
      app: :comeonin,
      version: "0.1.0",
      elixir: "~> 1.0",
      name: "Comeonin",
      description: @description,
      package: package,
      source_url: "https://github.com/elixircnx/comeonin",
      compilers: [:comeonin, :elixir, :app],
      deps: deps
    ]
  end

  def application do
    [applications: [:crypto, :logger]]
  end

  defp deps do
    [
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc,  "~> 0.7", only: :dev}
    ]
  end

  defp package do
   [
     contributors: ["David Whitlock", "Ben Sharman"],
     licenses: ["BSD"],
     links: %{"GitHub" => "https://github.com/elixircnx/comeonin",
              "Docs"   => "http://hexdocs.pm/comeonin"}
   ]
  end
end
