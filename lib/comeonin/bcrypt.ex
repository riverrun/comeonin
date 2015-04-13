defmodule Comeonin.Bcrypt do
  @moduledoc """
  Module to handle bcrypt authentication.

  Bcrypt is a key derivation function for passwords designed by Niels Provos
  and David Mazières. Bcrypt uses a salt to protect against offline attacks.
  It is also an adaptive function, which means that it can be configured
  to remain slow and resistant to brute-force attacks even as computational
  power increases.

  This bcrypt implementation is based on the latest OpenBSD version, which
  fixed a small issue that affected some passwords longer than 72 characters.
  """

  use Bitwise
  alias Comeonin.Tools
  alias Comeonin.Config

  #@on_load {:init, 0}

  def init do
    path = :filename.join(:code.priv_dir(:comeonin), 'bcrypt_nif')
    :ok = :erlang.load_nif(path, 0)
  end

  @doc """
  Generate a salt for use with the `hashpass` function.

  The log_rounds parameter determines the computational complexity
  of the generation of the salt. Its default is 12, the minimum is 4,
  and the maximum is 31.
  """
  def gen_salt(log_rounds) when log_rounds in 4..31 do
    :crypto.rand_bytes(16) |> format(log_rounds)
  end
  def gen_salt(_), do: gen_salt(Config.bcrypt_log_rounds)
  def gen_salt, do: gen_salt(Config.bcrypt_log_rounds)

  @doc """
  Hash the password using bcrypt.
  """
  def hashpass(password, salt) when is_binary(salt) and is_binary(password) do
    if byte_size(salt) == 29 do
      hashpw(password, salt)
    else
      raise ArgumentError, message: "The salt is the wrong length."
    end
  end
  def hashpass(_password, _salt) do
    raise ArgumentError, message: "Wrong type. The password and salt need to be strings."
  end

  def hashpw(password, salt) do
    [_, prefix, rounds, salt] = String.split(salt, "$")
    bcrypt(password, salt, prefix, rounds) |> format(salt, rounds)
  end

  defp format(salt, rounds) do
    "$2b$#{rounds}$#{Tools.bcrypt64enc(salt)}"
  end
  defp format(hash, salt, rounds) do
    "$2b$#{rounds}$#{Tools.bcrypt64enc(salt)}$#{Tools.bcrypt64enc(hash)}"
  end

  defp bcrypt(key, salt, prefix, rounds) do
    key_len = byte_size(key) + 1
    if prefix == "2b" and key_len > 73, do: key_len = 73
    {logr, salt} = check_salt(salt, rounds)
    expand_keys(key, key_len, logr, salt)
    bcrypt_encrypt
    finalize
  end

  defp check_salt(salt, rounds) when rounds in 4..31 do
    {bsl(1, String.to_integer(rounds)), Tools.bcrypt64dec(salt)}
  end
  defp check_salt(_, _), do: raise(ArgumentError, message: "Wrong number of rounds.")

  defp expand_keys(key, key_len, logr, salt, salt_len \\ 16) do
    #blowfish_initstate(blf_ctx state)
    #blowfish_expandstate(blf_ctx state, salt, salt_len, key, key_len)
    #blowfish_expand0state in loop(blf_ctx state, key, key_len) loop is logr long
  end

  defp bcrypt_encrypt() do
    #another NIF?
  end

  defp finalize() do
    Tools.bcrypt64enc
  end

  defp iterate(_password, 0, _prev, acc), do: acc
  defp iterate(password, round, prev, acc) do
    #next = :crypto.hmac(:sha512, password, prev)
    #iterate(password, round - 1, next, :crypto.exor(next, acc))
  end

  @doc """
  Hash the password with a salt which is randomly generated.

  There is an option to change the log_rounds parameter, which
  affects the complexity of the generation of the salt.
  """
  def hashpwsalt(password, log_rounds \\ Config.bcrypt_log_rounds) do
    hashpass(password, gen_salt(log_rounds))
  end

  @doc """
  Check the password.

  The check is performed in constant time to avoid timing attacks.
  """
  def checkpw(password, hash) do
    [_, prefix, rounds, salt, hash] = String.split(hash, "$")
    bcrypt(password, salt, prefix, rounds) |> Tools.secure_check(hash)
  end

  @doc """
  Perform a dummy check for a user that does not exist.
  This always returns false. The reason for implementing this check is
  in order to make user enumeration by timing responses more difficult.
  """
  def dummy_checkpw do
    hashpwsalt("password")
    false
  end
end
