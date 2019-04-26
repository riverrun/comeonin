defmodule Comeonin do
  @moduledoc """
  Defines a behaviour for higher-level password hashing functions.
  """

  @type opts :: keyword
  @type password :: binary
  @type user_struct :: map | nil

  @doc """
  Hashes a password and returns the password hash in a map, with the
  password set to nil.

  In the default implementation, the key for the password hash is
  `:password_hash`. A different key can be used by using the `hash_key`
  option.

  ## Example with Ecto

  The `put_pass_hash` function below is an example of how you can use
  `add_hash` to add the password hash to the Ecto changeset.

      defp put_pass_hash(%Ecto.Changeset{valid?: true, changes:
          %{password: password}} = changeset) do
        change(changeset, add_hash(password))
      end

      defp put_pass_hash(changeset), do: changeset

  This function will return a changeset with `%{password_hash: password_hash, password: nil}`
  added to the `changes` map.
  """
  @callback add_hash(password, opts) :: map

  @doc """
  Checks the password by comparing its hash with the password hash found
  in a user struct, or map.

  The first argument to `check_pass` should be a user struct, a regular
  map, or nil.

  In the default implementation, if the input to the first argument,
  the user struct, is nil, then the `no_user_verify` function is run,
  so as to prevent user enumeration. This can be disabled by setting
  the `hide_user` option to false.

  ## Example

  The following is an example of calling this function with no options:

  ```elixir
  def verify_user(%{"password" => password} = params) do
    params
    |> Accounts.get_by()
    |> check_pass(password)
  end
  ```

  The `Accounts.get_by` function in this example takes the user parameters
  (for example, email and password) as input and returns a user struct or nil.

  If your user map stores the password in the key `:pw_hash` instead of the
  default `password_hash`, you can do

  ```elixir
  case check_pass(user, hash_key: :pw_hash) do
    {:ok, user} ->
      # user is not nil and the password is verified
      {:ok, user}

    {:error, msg} ->
      # User was nil or the password did not hash to the value in :pw_hash.
      # The string value of msg will tell you which.
      {:error, msg}
  end
  ```
  """
  @callback check_pass(user_struct, password, opts) :: {:ok, map} | {:error, String.t()}

  @doc """
  Runs the password hash function, but always returns false.

  This function is intended to make it more difficult for any potential
  attacker to find valid usernames by using timing attacks. This function
  is only useful if it is used as part of a policy of hiding usernames.

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
  @callback no_user_verify(opts) :: false

  defmacro __using__(_) do
    quote do
      @behaviour Comeonin
      @behaviour Comeonin.PasswordHash

      @impl Comeonin
      def add_hash(password, opts \\ []) do
        hash_key = opts[:hash_key] || :password_hash
        %{hash_key => hash_pwd_salt(password, opts), :password => nil}
      end

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

      @impl Comeonin
      def no_user_verify(opts \\ []) do
        hash_pwd_salt("", opts)
        false
      end

      defoverridable Comeonin
    end
  end
end
