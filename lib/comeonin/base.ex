for {module, alg} <- [{Argon2, "Argon2"}, {Bcrypt, "Bcrypt"}, {Pbkdf2, "Pbkdf2"}] do
  if Code.ensure_loaded?(module) do
    mod = Module.concat(Comeonin, module)
    defmodule mod do
      @moduledoc """
      Password hashing module using the #{alg} algorithm.

      For more information about the #{alg} algorithm, see the `Choosing
      an algorithm` section in the Comeonin docs.

      For a lower-level API, see `#{alg}.Base`.
      """

      @doc """
      Hash a password and return it in a map, with the password set to nil.

      ## Options

      This function uses `#{alg}.hash_pwd_salt` as the hashing function.
      In addition to the options for hash_pwd_salt, there is also the following
      option:

        * hash_key - the name of the key for the password hash
          * the default is :password_hash

      ## Examples

      In the following example, this function is used with an Ecto changeset:

          defp put_pass_hash(%Ecto.Changeset{valid?: true, changes:
              %{password: password}} = changeset) do
            change(changeset, Comeonin.#{alg}.add_hash(password))
          end
          defp put_pass_hash(changeset), do: changeset

      """
      def add_hash(password, opts \\ []) do
        hash_key = opts[:hash_key] || :password_hash
        %{hash_key => unquote(module).hash_pwd_salt(password, opts), :password => nil}
      end

      @doc """
      Check the password by comparing its hash with the password hash found
      in a user struct, or map.

      The password hash's key needs to be either `:password_hash` or
      `:encrypted_password`.

      After finding the password hash in the user struct, the password
      is checked by comparing it with the hash. Then the function returns
      {:ok, user} or {:error, message}. Note that the error message is
      meant to be used for logging purposes only; it should not be passed
      on to the end user.

      If the first argument is nil, meaning that there is no user with that
      name, a dummy verify function is run to make user enumeration, using
      timing information, more difficult. This can be disabled by adding
      `hide_user: false` to the opts.

      ## Examples

      The following is a simple example using Phoenix 1.3:

          def verify(attrs) do
            MyApp.Accounts.get_by(attrs)
            |> Comeonin.#{alg}.check_pass(password)
          end

      """
      def check_pass(user, password, opts \\ [])
      def check_pass(nil, _password, opts) do
        unless opts[:hide_user] == false, do: unquote(module).no_user_verify(opts)
        {:error, "invalid user-identifier"}
      end
      def check_pass(user, password, _) do
        with {:ok, hash} <- get_hash(user) do
          unquote(module).verify_pass(password, hash) and
          {:ok, user} || {:error, "invalid password"}
        end
      end

      @doc """
      Print out a report to help you configure the hash function.

      For more details, see the documentation for `#{alg}.Stats.report`.
      """
      def report(opts \\ []) do
        mod = Module.concat(unquote(module), Stats)
        mod.report(opts)
      end

      @doc """
      Hash the password with a randomly-generated salt.

      For more details, see the documentation for `#{alg}.hash_pwd_salt`
      and `#{alg}.Base.hash_password`.
      """
      defdelegate hashpwsalt(password, opts \\ []), to: module, as: :hash_pwd_salt

      @doc """
      Check the password by comparing it with the stored hash.

      For more details, see the documentation for `#{alg}.verify_pass`.
      """
      defdelegate checkpw(password, hash), to: module, as: :verify_pass

      @doc """
      Run a dummy check, which always returns false, to make user enumeration
      more difficult.

      For more details, see the documentation for `#{alg}.no_user_verify`.
      """
      defdelegate dummy_checkpw(opts \\ []), to: module, as: :no_user_verify

      defp get_hash(%{password_hash: hash}), do: {:ok, hash}
      defp get_hash(%{encrypted_password: hash}), do: {:ok, hash}
      defp get_hash(_), do: {:error, "no password hash found in the user struct"}
    end
  end
end
