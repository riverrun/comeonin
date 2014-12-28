defmodule Comeonin.Bcrypt do
  @moduledoc """
  Module to handle Bcrypt authentication.
  """

  @on_load {:init, 0}
  @log_rounds 12

  def init do
    path = :filename.join(:code.priv_dir(:comeonin), 'bcrypt_nif')
    :ok = :erlang.load_nif(path, 0)
  end

  @doc """
  Generate a salt for use with the `hashpw`, `hashpass` and
  `hashpwsalt` functions.

  The log_rounds parameter determines the computational complexity
  of the hashing. Its default is 10, the minimum is 4, and the maximum
  is 31.
  """
  def gen_salt(log_rounds) do
    :crypto.rand_bytes(16) |> encode_salt(log_rounds)
  end

  def encode_salt(_rand_num, _log_rounds) do
    exit(:nif_library_not_loaded)
  end

  @doc """
  Hash the password using Bcrypt.
  """
  def hashpass(password, salt) do
    String.to_char_list(password) |> hashpw(salt) |> :erlang.list_to_binary
  end
  def hashpw(_password, _salt) do
    exit(:nif_library_not_loaded)
  end

  @doc """
  Hash the password with a salt.

  The salt is randomly generated.
  """
  def hashpwsalt(password) do
    salt = gen_salt(@log_rounds)
    hashpass(password, salt)
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
    hashpw(password, hash) |> secure_check(hash)
  end
  def checkpw do
    checkpw("", "$2a$05$CCCCCCCCCCCCCCCCCCCCC.7uG0VCzI2bS7j6ymqJi9CdcdxiRTWNy")
    false
  end

  @doc """
  Compares the two binaries in constant time to avoid timing attacks.
  """
  def secure_check(hash, stored) do
    if length(hash) == length(stored) do
      secure_check(hash, stored, 0) == 0
    else
      false
    end
  end
  defp secure_check([h|hs], [s|ss], acc) do
    import Bitwise
    secure_check(hs, ss, acc ||| (h ^^^ s))
  end
  defp secure_check([], [], acc) do
    acc
  end
end
