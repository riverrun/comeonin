defmodule Comeonin.PasswordHash do
  @moduledoc """
  Defines a behaviour for password hashing functions.
  """

  @type opts :: keyword
  @type password :: binary
  @type password_hash :: binary

  @doc """
  Generates a random salt and then hashes the password.
  """
  @callback hash_pwd_salt(password, opts) :: password_hash

  @doc """
  Checks the password by comparing it with a stored hash.

  Please note that the first argument to `verify_pass` should be the
  password, and the second argument should be the password hash.
  """
  @callback verify_pass(password, password_hash) :: boolean
end
