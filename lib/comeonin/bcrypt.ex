defmodule Comeonin.Bcrypt do
  @moduledoc """
  Module to handle Bcrypt authentication.
  """

  @log_rounds 12

  @doc """
  Generate a salt for use with the `hashpw` function.

  The log_rounds parameter determines the computational complexity
  of the hashing. Its default is 12, the minimum is 4, and the maximum
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
  def hashpw(password, salt) do
    password = String.to_char_list(password)
    {:ok, hash} = :bcrypt.hashpw(password, salt)
    :erlang.list_to_binary(hash)
  end

  @doc """
  Hash the password with a salt.

  The salt is randomly generated with the default arguments.
  """
  def hashpwsalt(password, @log_rounds) do
    salt = gen_salt(log_rounds)
    hashpw(password, salt)
  end

  @doc """
  Check the password.

  Perform a dummy check for a user that does not exist.
  This always returns false.

  The reason for implementing this check is in order to make
  user enumeration by timing responses more difficult.
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

  @doc """
  Compares the two binaries in constant time to avoid timing attacks.
  """
  def secure_check(hash, stored) do
    if byte_size(hash) == byte_size(stored) do
      arithmetic_compare(hash, stored, 0) == 0
    else
      false
    end
  end
  defp secure_check(<<x, left :: binary>>, <<y, right :: binary>>, acc) do
    import Bitwise
    secure_check(left, right, acc ||| (x ^^^ y))
  end
  defp secure_check("", "", acc) do
    acc
  end
end
