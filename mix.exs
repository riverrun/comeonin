defmodule Mix.Tasks.Compile.Comeonin do
  @shortdoc "Compiles Comeonin"

  def run(_) do
    File.mkdir("priv")
    {exec, args} = case :os.type do
      {:win32, _} ->
        {"nmake", ["/F", "Makefile.win", "priv\\bcrypt_nif.dll"]}
      {:unix, :freebsd} ->
        {"gmake", ["priv/bcrypt_nif.so"]}
      _ ->
        {"make", ["priv/bcrypt_nif.so"]}
    end

    {result, _error_code} = System.cmd(exec, args, stderr_to_stdout: true)
    Mix.shell.info result
  end
end

defmodule Comeonin.Mixfile do
  use Mix.Project

  @description """
  Password hashing (bcrypt, pbkdf2_sha512) library for Elixir.
  """

  def project do
    [
      app: :comeonin,
      version: "0.3.1",
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
      files: ["lib", "c_src", "mix.exs", "Makefile*", "README.md", "LICENSE"],
      contributors: ["David Whitlock", "Ben Sharman", "Jason M Barnes"],
      licenses: ["BSD"],
      links: %{"GitHub" => "https://github.com/elixircnx/comeonin",
        "Docs"   => "http://hexdocs.pm/comeonin"}
    ]
  end
end
