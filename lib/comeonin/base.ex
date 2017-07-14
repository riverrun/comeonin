for {module, alg} <- [{Argon2, "Argon2"}, {Bcrypt, "Bcrypt"}, {Pbkdf2, "Pbkdf2"}] do
  if Code.ensure_loaded?(module) do
    mod = Module.concat(Comeonin, module)
    defmodule mod do
      @moduledoc """
      Password hashing module using the #{alg} algorithm.

      For a lower-level API, see `#{alg}.Base`.
      """

      @doc """
      Hash a password and return it in a map with the password set to nil.

      ## Examples

      In the following example, this function is used with an Ecto changeset:

          defp put_pass_hash(%Ecto.Changeset{valid?: true, changes:
              %{password: password}} = changeset) do
            change(changeset, Comeonin.#{alg}.add_hash(password))
          end
          defp put_pass_hash(changeset), do: changeset
      """
      def add_hash(password, opts \\ []) do
        %{password_hash: unquote(module).hash_pwd_salt(password, opts), password: nil}
      end

      @doc """
      Check the password by comparing its hash with a stored password hash,
      within a user struct, or map.

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
        unless opts[:hide_user] == false do
          unquote(module).no_user_verify(opts)
        end
        {:error, "invalid user-identifier"}
      end
      def check_pass(%{password_hash: hash} = user, password, _) do
        unquote(module).verify_pass(password, hash) and
        {:ok, user} || {:error, "invalid password"}
      end

      @doc """
      Print out a report to help you configure the hash function.

      For more details, see the documentation for `#{alg}.Stats.report`
      function.
      """
      def report(opts \\ []) do
        mod = Module.concat(unquote(module), Stats)
        mod.report(opts)
      end

      defdelegate hashpwsalt(password, opts \\ []), to: module, as: :hash_pwd_salt

      defdelegate checkpw(password, hash), to: module, as: :verify_pass

      defdelegate dummy_checkpw(opts \\ []), to: module, as: :no_user_verify
    end
  end
end
