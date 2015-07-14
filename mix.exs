defmodule Mix.Tasks.Compile.Comeonin do
  @shortdoc "Compiles Comeonin"

  def run(_) do
    File.mkdir("priv")
    {exec, args} = case :os.type do
      {:win32, _} ->
        {"nmake", ["/F", "Makefile.win", "priv\\bcrypt_nif.dll"]}
      {:unix, :freebsd} ->
        {"gmake", ["priv/bcrypt_nif.so"]}
      {:unix, :openbsd} ->
        {"gmake", ["priv/bcrypt_nif.so"]}
      _ ->
        {"make", ["priv/bcrypt_nif.so"]}
    end

    {result, error_code} = System.cmd(exec, args, stderr_to_stdout: true)
    if error_code != 0 do
      handle_error
    else
      IO.binwrite result
    end
  end

  defp handle_error do
    raise Mix.Error, message: """
    Could not compile Comeonin.
    Please make sure that you are using Erlang / OTP version 17.0 or later
    and that you have a C compiler installed.
    Please follow the directions below for the operating system you are
    using:

    Windows: One option is to install a recent version of Visual Studio (the
    free Community edition will be enough for this task). Then try running
    `mix deps.compile comeonin` from the `Developer Command Prompt`. If
    you are using 64-bit erlang, you might need to run the command
    `vcvarsall.bat amd64` before running `mix deps.compile`. Further
    information can be found at
    (https://msdn.microsoft.com/en-us/library/x4d2c09s.aspx).

    Mac OS X: You need to have gcc and make installed. Try running the
    commands `gcc --version` and / or `make --version`. If these programs
    are not installed, you will be prompted to install them.

    Linux: You need to have gcc and make installed. If you are using
    Ubuntu or any other Debian-based system, install the packages
    `build-essential`. Also install `erlang-dev` package if not
    included in your Erlang/OTP version.

    """
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
      version: "1.0.5",
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
        "Docs" => "http://hexdocs.pm/comeonin"}
    ]
  end
end
