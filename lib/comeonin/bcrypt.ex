defmodule Comeonin.Bcrypt do
  @moduledoc """
  Module to handle Bcrypt authentication.
  """

  @doc """
  Generate a salt for use with the `hashpw` function.

  The log_rounds parameter determines the computational complexity
  of the hashing. Its default is 10, the minimum is 4, and the maximum
  is 31.
  """
  def gensalt(log_rounds) when log_rounds >= 4 and log_rounds <= 31 do
    {:ok, salt} = :bcrypt.gen_salt(log_rounds)
    salt
  end
  def gensalt(_) do
    raise ArgumentError,
    message: "Wrong number of rounds for gensalt. Log_rounds should be between 4 and 31 (default is 10)."
  end

  @doc """
  Hash the password using Bcrypt.
  """
  def hashpw(password, salt) do
    password = String.to_char_list(password)
    {:ok, hash} = :bcrypt.hashpw(password, salt)
    :erlang.list_to_binary(hash)
  end

  @doc """
  Check the password.

  Perform a dummy check for a user that does not exist.
  This always returns false.

  The reason for implementing this check is in order to make
  user enumeration via timing attacks more difficult.
  """
  def checkpw(password, hash) do
    password = String.to_char_list(password)
    hash = String.to_char_list(hash)
    {:ok, hash} == :bcrypt.hashpw(password, hash)
  end
  def checkpw do
    checkpw("", "$2a$05$CCCCCCCCCCCCCCCCCCCCC.7uG0VCzI2bS7j6ymqJi9CdcdxiRTWNy")
    false
  end
end
