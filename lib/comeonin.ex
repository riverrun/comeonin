defmodule Comeonin do
  @moduledoc """
  Module to make authorization of users more straightforward.

  At the moment, this just supports Bcrypt.
  """

  alias Comeonin.Bcrypt

  @doc """
  Hash the password.
  """
  def hash_password(password, log_rounds \\ 10) do
    salt = Bcrypt.gen_salt(log_rounds)
    Bcrypt.hash_password(password, salt)
  end

  @doc """
  Check the password.
  """
  def check_password(password, stored_hash) do
    Bcrypt.check_password(password, stored_hash)
  end

  @doc """
  Perform a dummy check for a user that does not exist.
  This always returns false.

  The reason for implementing this check is in order to make
  user enumeration via timing attacks more difficult.
  """
  def dummy_check do
    Bcrypt.check_password("", "$2a$05$CCCCCCCCCCCCCCCCCCCCC.VGOzA784oUp/Z0DY336zx7pLYAy0lwK")
  end
end
