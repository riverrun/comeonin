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

  alias Comeonin.Tools

  @on_load {:init, 0}
  @log_rounds 12

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
  def gen_salt(log_rounds) when is_integer(log_rounds) do
    :crypto.rand_bytes(16) |> encode_salt(log_rounds)
  end
  def gen_salt(_), do: gen_salt(@log_rounds)
  def gen_salt, do: gen_salt(@log_rounds)

  defp encode_salt(_rand_num, _log_rounds) do
    exit(:nif_library_not_loaded)
  end

  @doc """
  Hash the password using bcrypt.
  """
  def hashpass(password, salt) when is_binary(salt) do
    if String.length(salt) == 29 do
      salt = String.to_char_list(salt)
      hashpass(password, salt)
    else
      raise ArgumentError, message: "The salt is the wrong length."
    end
  end
  def hashpass(password, salt) when is_binary(password) do
    String.to_char_list(password) |> hashpw(salt) |> :erlang.list_to_binary
  end
  def hashpass(_password, _salt) do
    raise ArgumentError, message: "Wrong type. The password needs to be a string."
  end
  defp hashpw(_password, _salt) do
    exit(:nif_library_not_loaded)
  end

  @doc """
  Hash the password with a salt which is randomly generated.

  There is an option to change the log_rounds parameter, which
  affects the complexity of the generation of the salt.
  """
  def hashpwsalt(password, log_rounds \\ @log_rounds) do
    salt = gen_salt(log_rounds)
    hashpass(password, salt)
  end

  @doc """
  Check the password.

  The check is performed in constant time to avoid timing attacks.
  """
  def checkpw(password, hash) do
    password = String.to_char_list(password)
    hash = String.to_char_list(hash)
    hashpw(password, hash) |> Tools.secure_check(hash)
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
