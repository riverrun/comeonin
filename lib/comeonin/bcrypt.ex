defmodule Comeonin.Bcrypt do
  @moduledoc """
  Module to handle Bcrypt authentication.
  """

  @doc """
  Generate a salt for use with the `hash_password` function.

  The log_rounds parameter determines the computational complexity
  of the hashing. Its default is 10, the minimum is 4, and the maximum
  is 31.
  """
  def gen_salt(log_rounds) when log_rounds >= 4 and log_rounds <= 31 do
    {:ok, salt} = :bcrypt.gen_salt(log_rounds)
    salt
  end
  def gen_salt(_) do
    raise ArgumentError,
    message: "Wrong number of rounds for gen_salt. Log_rounds should be between 4 and 31 (default is 10)."
  end

  @doc """
  Hash the password using Bcrypt.
  """
  def hash_password(password, salt) do
    password = String.to_char_list(password)
    {:ok, hash} = :bcrypt.hashpw(password, salt)
    :erlang.list_to_binary(hash)
  end

  @doc """
  Check the password.
  """
  def check_password(password, stored_hash) do
    password = String.to_char_list(password)
    {:ok, hash} = :bcrypt.hashpw(password, stored_hash)
    :erlang.list_to_binary(hash) == stored_hash
  end

  @doc """
  Perform a dummy check for a user that does not exist.
  This always returns false.

  The reason for implementing this check is in order to make
  user enumeration via timing attacks more difficult.
  """
  def dummy_check do
    check_password("", "$2a$05$CCCCCCCCCCCCCCCCCCCCC.VGOzA784oUp/Z0DY336zx7pLYAy0lwK")
  end
end
