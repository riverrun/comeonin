for {module, alg} <- [{Argon2, "Argon2"}, {Bcrypt, "Bcrypt"}, {Pbkdf2, "Pbkdf2"}] do
  if Code.ensure_loaded?(module) do
    mod = Module.concat(Comeonin, module)
    defmodule mod do
      @moduledoc """
      Password hashing using the #{alg} algorithm.

      See the documentation for `#{alg}` for more information.
      """

      defdelegate hashpwsalt(password, opts \\ []), to: module, as: :hash_pwd_salt

      @doc """
      Check the password by comparing it with the stored hash.

      See the documentation for `#{alg}.verify_hash`
      for details about the available options.
      """
      def checkpw(password, hash, opts \\ []) do
        unquote(module).verify_hash(hash, password, opts)
      end

      defdelegate dummy_checkpw(opts \\ []), to: module, as: :no_user_verify
   end
  end
end
