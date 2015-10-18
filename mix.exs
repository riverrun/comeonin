defmodule Mix.Tasks.Compile.Comeonin do
  @shortdoc "Compiles Comeonin"

  def run(_) do
    if Mix.env != :test, do: File.rm_rf("priv")
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

    if System.find_executable(exec) do
      build(exec, args)
      Mix.Project.build_structure
      :ok
    else
      nocompiler_error(exec)
    end
  end

  def build(exec, args) do
    {result, error_code} = System.cmd(exec, args, stderr_to_stdout: true)
    IO.binwrite result
    if error_code != 0, do: build_error(exec)
  end

  defp nocompiler_error("nmake") do
    raise Mix.Error, message: nocompiler_message("nmake") <> windows_message
  end
  defp nocompiler_error(exec) do
    raise Mix.Error, message: nocompiler_message(exec) <> nix_message
  end

  defp build_error("nmake") do
    raise Mix.Error, message: build_message <> windows_message
  end
  defp build_error(_) do
    raise Mix.Error, message: build_message <> nix_message
  end

  defp nocompiler_message(exec) do
    """
    Could not find the program `#{exec}`.

    You will need to install the C compiler `#{exec}` to be able to build
    Comeonin.

    """
  end

  defp build_message do
    """
    Could not compile Comeonin.

    Please make sure that you are using Erlang / OTP version 17.0 or later
    and that you have a C compiler installed.

    """
  end

  defp windows_message do
    """
    One option is to install a recent version of Visual Studio (the
    free Community edition will be enough for this task). Then try running
    `mix deps.compile comeonin` from the `Developer Command Prompt`.

    If you are using 64-bit erlang, you might need to run the command
    `vcvarsall.bat amd64` in the Visual Studio {version}\VC directory
    before running `mix deps.compile`.
    See: https://msdn.microsoft.com/en-us/library/x4d2c09s.aspx

    If you are using Visual Studio 2015, you need to install the C++ build
    tools before running the `vcvarsall.bat amd64`. Do this by going to
    "Create New Project" and select "C++" to prompt to install the
    required dependencies.
    See: https://msdn.microsoft.com/en-us/library/60k1461a.aspx

    """
  end

  defp nix_message do
    """
    Please follow the directions below for the operating system you are
    using:

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
      version: "1.3.0",
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
      {:ex_doc,  "~> 0.10", only: :dev}
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
