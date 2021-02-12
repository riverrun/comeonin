defmodule Comeonin do
  @moduledoc """
  Defines a behaviour for higher-level password hashing functions.
  """

  @type opts :: keyword
  @type password :: binary
  @type user_struct :: map | nil

  @doc deprecated: "This function will be removed in the next major version."
  @callback add_hash(password, opts) :: map

  @doc deprecated: "This function will be removed in the next major version."
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

      @impl Comeonin
      @deprecated "This function will be removed in the next major version."
      def add_hash(password, opts \\ []) do
        hash_key = opts[:hash_key] || :password_hash
        %{hash_key => hash_pwd_salt(password, opts)}
      end

      @impl Comeonin
      @deprecated "This function will be removed in the next major version."
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
