for {module, alg} <- [{Argon2, "Argon2"}, {Bcrypt, "Bcrypt"}, {Pbkdf2, "Pbkdf2"}] do
  if Code.ensure_loaded?(module) do
    mod = Module.concat(Comeonin, module)
    defmodule mod do
      @moduledoc """
      Password hashing using the #{alg} algorithm.

      This module provides the following three functions:

        * hashpwsalt - hash the password with a random salt
          * see #{alg}.hash_pwd_salt for details about the available options
        * checkpw - check the password by comparing it with the stored hash
          * see #{alg}.verify_pass for details about the available options
        * dummy_checkpw - a dummy check, which always returns false
          * this can be used to make user enumeration more difficult
          * see #{alg}.no_user_verify for details about the available options

      For a lower-level API, see `#{alg}.Base`.
      """

      defdelegate hashpwsalt(password, opts \\ []), to: module, as: :hash_pwd_salt

      defdelegate checkpw(password, hash, opts \\ []), to: module, as: :verify_pass

      defdelegate dummy_checkpw(opts \\ []), to: module, as: :no_user_verify
   end
  end
end
