defmodule Comeonin do
  @moduledoc """
  Defines a behaviour for higher-level password hashing functions.
  """

  @type opts :: keyword
  @type password :: binary
  @type user_struct :: map | nil

  @doc """
  Hashes a password and returns the password hash in a map.
  """
  @callback add_hash(password, opts) :: map

  @doc """
  Checks the password by comparing its hash with the password hash found
  in a user struct, or map.

  The first argument to `check_pass/3` should be a user struct, a regular
  map, or nil.
  """
  @callback check_pass(user_struct, password, opts) :: {:ok, map} | {:error, String.t()}

  @doc """
  Runs the password hash function, but always returns false.

  This function is intended to make it more difficult for any potential
  attacker to find valid usernames by using timing attacks. This function
  is only useful if it is used as part of a policy of hiding usernames.
  """
  @callback no_user_verify(opts) :: false

  defmacro __using__(_) do
    quote do
      @behaviour Comeonin
      @behaviour Comeonin.PasswordHash

      @doc """
      Hashes a password, using `hash_pwd_salt/2`, and returns the password hash in a map.

      This is a convenience function that is especially useful when used with
      Ecto changesets.

      ## Options

      In addition to the `:hash_key` option show below, this function also takes
      options that are then passed on to the `hash_pwd_salt/2` function in this
      module.

      See the documentation for `hash_pwd_salt/2` for further details.

        * `:hash_key` - the password hash identifier
          * the default is `:password_hash`

      ## Example with Ecto

      The `put_pass_hash` function below is an example of how you can use
      `add_hash` to add the password hash to the Ecto changeset.

          defp put_pass_hash(%Ecto.Changeset{valid?: true, changes:
              %{password: password}} = changeset) do
            change(changeset, add_hash(password))
          end

          defp put_pass_hash(changeset), do: changeset

      This function will return a changeset with `%{password_hash: password_hash}`
      added to the `changes` map.
      """
      @impl Comeonin
      def add_hash(password, opts \\ []) do
        hash_key = opts[:hash_key] || :password_hash
        %{hash_key => hash_pwd_salt(password, opts)}
      end

      @doc """
      Checks the password, using `verify_pass/2`, by comparing the hash with
      the password hash found in a user struct, or map.

      This is a convenience function that takes a user struct, or map, as input
      and seamlessly handles the cases where no user is found.

      ## Options

        * `:hash_key` - the password hash identifier
          * this does not need to be set if the key is `:password_hash` or `:encrypted_password`
        * `:hide_user` - run the `no_user_verify/1` function if no user is found
          * the default is true

      ## Example

      The following is an example of using this function to verify a user's
      password:

          def verify_user(%{"password" => password} = params) do
            params
            |> Accounts.get_by()
            |> check_pass(password)
          end

      The `Accounts.get_by` function in this example takes the user parameters
      (for example, email and password) as input and returns a user struct or nil.
      """
      @impl Comeonin
      def check_pass(user, password, opts \\ [])

      def check_pass(nil, _password, opts) do
        unless opts[:hide_user] == false, do: no_user_verify(opts)
        {:error, "invalid user-identifier"}
      end

      def check_pass(user, password, opts) when is_binary(password) do
        case get_hash(user, opts[:hash_key]) do
          {:ok, hash} ->
            if verify_pass(password, hash), do: {:ok, user}, else: {:error, "invalid password"}

          _ ->
            {:error, "no password hash found in the user struct"}
        end
      end

      def check_pass(_, _, _) do
        {:error, "password is not a string"}
      end

      defp get_hash(%{password_hash: hash}, nil), do: {:ok, hash}
      defp get_hash(%{encrypted_password: hash}, nil), do: {:ok, hash}
      defp get_hash(_, nil), do: nil

      defp get_hash(user, hash_key) do
        if hash = Map.get(user, hash_key), do: {:ok, hash}
      end

      @doc """
      Runs the password hash function, but always returns false.

      This function is intended to make it more difficult for any potential
      attacker to find valid usernames by using timing attacks. This function
      is only useful if it is used as part of a policy of hiding usernames.

      ## Options

      This function should be called with the same options as those used by
      `hash_pwd_salt/2`.

      ## Hiding usernames

      In addition to keeping passwords secret, hiding the precise username
      can help make online attacks more difficult. An attacker would then
      have to guess a username / password combination, rather than just
      a password, to gain access.

      This does not mean that the username should be kept completely secret.
      Adding a short numerical suffix to a user's name, for example, would be
      sufficient to increase the attacker's work considerably.

      If you are implementing a policy of hiding usernames, it is important
      to make sure that the username is not revealed by any other part of
      your application.
      """
      @impl Comeonin
      def no_user_verify(opts \\ []) do
        hash_pwd_salt("", opts)
        false
      end

      defoverridable Comeonin
    end
  end
end
