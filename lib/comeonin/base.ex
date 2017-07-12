for {module, alg} <- [{Argon2, "Argon2"}, {Bcrypt, "Bcrypt"}, {Pbkdf2, "Pbkdf2"}] do
  if Code.ensure_loaded?(module) do
    mod = Module.concat(Comeonin, module)
    defmodule mod do
      @moduledoc """
      Password hashing using the #{alg} algorithm.

      See the documentation for `#{alg}` for more information.
      """

      defdelegate hashpwsalt(password, opts \\ []), to: module, as: :hash_pwd_salt

      defdelegate checkpw(password, hash, opts \\ []), to: module, as: :verify_pass

      defdelegate dummy_checkpw(opts \\ []), to: module, as: :no_user_verify
   end
  end
end
