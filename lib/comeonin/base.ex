for {module, alg} <- [{Argon2, "Argon2"}, {Bcrypt, "Bcrypt"}, {Pbkdf2, "Pbkdf2"}] do
  if Code.ensure_loaded?(module) do
    mod = Module.concat(Comeonin, module)

    defmodule mod do
      @moduledoc """
      Password hashing module using the #{alg} algorithm.

      For more information about the #{alg} algorithm, see the `Choosing
      an algorithm` section in the Comeonin documentation.

      For a lower-level API, see `#{alg}.Base`.
      """

      @doc """
      Hash a password and return it in a map, with the password set to nil.

      ## Options

      This function uses `#{alg}.hash_pwd_salt` as the hashing function.
      In addition to the options for hash_pwd_salt, there is also the following
      option:

        * `:hash_key` - the name of the key for the password hash
          * the default is `:password_hash`

      ## Example with Ecto

      In this example, the `create_changeset` function below shows how a new
      user can be created:

          def create_changeset(%User{} = user, attrs) do
            user
            |> changeset(attrs)
            |> validate_password(:password)
            |> put_pass_hash()
          end

      The `validating the password` section will then look at writing
      a custom validator (validate_password), and the `adding the password hash`
      section will cover the use of the `add_hash` function (in put_pass_hash).

      ### Validating the password

      This section can be skipped if you are using a frontend solution
      to validating the password.

      The following is a basic example of the `validate_password`
      function:

          def validate_password(changeset, field, options \\ []) do
            validate_change(changeset, field, fn _, password ->
              case valid_password?(password) do
                {:ok, _} -> []
                {:error, msg} -> [{field, options[:message] || msg}]
              end
            end)
          end

      In the example below, the `valid_password?` function checks that
      the password is at least 8 characters long.

          defp valid_password?(password) when byte_size(password) > 7 do
            {:ok, password}
          end
          defp valid_password?(_), do: {:error, "The password is too short"}

      Alternatively, you could use a dedicated password strength checker,
      such as [not_qwerty123](https://github.com/riverrun/not_qwerty123).

      For more information about password strength rules, see the latest
      [NIST guidelines](https://pages.nist.gov/800-63-3/sp800-63b.html).

      ### Adding the password hash

      In the following example, `add_hash` is used in the put_pass_hash
      function:

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

      After finding the password hash in the user struct, the password
      is checked by comparing it with the hash. Then the function returns
      `{:ok, user}` or `{:error, message}`. Note that the error message is
      meant to be used for logging purposes only; it should not be passed
      on to the end user.

      ## Options

        * `:hide_user` - run a dummy verify function if the user is not found
          * see the documentation for `#{alg}.no_user_verify` for more details
          * the default is true
        * `:hash_key` - the name of the key for the password hash - in the user struct
          * if you use `:password_hash` or `:encrypted_password`, you do not need to set this

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

      def check_pass(user, password, opts) when is_binary(password) do
        case get_hash(user, opts[:hash_key]) do
          {:ok, hash} ->
            (unquote(module).verify_pass(password, hash) and {:ok, user}) ||
              {:error, "invalid password"}

          _ ->
            {:error, "no password hash found in the user struct"}
        end
      end

      def check_pass(_, _, _) do
        {:error, "password is not a string"}
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

      defp get_hash(%{password_hash: hash}, nil), do: {:ok, hash}
      defp get_hash(%{encrypted_password: hash}, nil), do: {:ok, hash}
      defp get_hash(_, nil), do: nil
      defp get_hash(user, hash_key), do: Map.get(user, hash_key) |> get_hash()

      defp get_hash(nil), do: nil
      defp get_hash(hash), do: {:ok, hash}
    end
  end
end
