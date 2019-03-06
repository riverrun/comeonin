# This file provides warnings for functions that were removed in
# version 5.0.

for {alg, version} <- [
      {"Argon2", "{:argon2_elixir, \"~> 2.0\"}"},
      {"Bcrypt", "{:bcrypt_elixir, \"~> 2.0\"}"},
      {"Pbkdf2", "{:pbkdf2_elixir, \"~> 1.0\"}"}
    ] do
  module = Module.concat([alg])
  mod = Module.concat(Comeonin, module)

  defmodule mod do
    @moduledoc false
    @dialyzer :no_return

    @doc false
    def add_hash(_, _ \\ []), do: error(:add_hash, :add_hash)

    @doc false
    def check_pass(_, _, _ \\ []), do: error(:check_pass, :check_pass)

    @doc false
    def hashpwsalt(_, _ \\ []), do: error(:hashpwsalt, :hash_pwd_salt)

    @doc false
    def checkpw(_, _), do: error(:checkpw, :verify_pass)

    @doc false
    def dummy_checkpw(_ \\ []), do: error(:dummy_checkpw, :no_user_verify)

    defp error(old, new) do
      raise ArgumentError, """
      #{inspect(__MODULE__)}.#{old} has been removed.
      Add #{unquote(version)} to the deps in your mix.exs file,
      and use #{inspect(unquote(module))}.#{new} instead.
      """
    end
  end
end
