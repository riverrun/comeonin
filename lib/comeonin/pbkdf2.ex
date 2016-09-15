defmodule Comeonin.Pbkdf2 do
  @moduledoc """
  Module to handle pbkdf2_sha512 authentication.

  To generate a password hash, use the `hashpwsalt` function:

      Comeonin.Pbkdf2.hashpwsalt("hard to guess")

  To check the password against a password hash, use the `checkpw` function:

      Comeonin.Pbkdf2.checkpw("hard to guess", stored_hash)

  There is also a `dummy_checkpw`, which can be used to stop an attacker guessing
  a username by timing the responses.

  See the documentation for each function for more details.

  Most users will not need to use any of the other functions in this module.

  ## Pbkdf2

  Pbkdf2 is a password-based key derivation function
  that uses a password, a variable-length salt and an iteration
  count and applies a pseudorandom function to these to
  produce a key.

  The original implementation used SHA-1 as the pseudorandom function,
  but this version uses HMAC-SHA-512.
  """

  use Bitwise
  alias Comeonin.{Pbkdf2.Base64, Config, Tools}

  @salt_length 16

  @doc """
  Generate a salt for use with the `hashpass` function.

  The minimum length of the salt is 16 and the maximum length
  is 1024. The default is 16.
  """
  def gen_salt(salt_length \\ @salt_length)
  def gen_salt(salt_length) when salt_length in 16..1024 do
    :crypto.strong_rand_bytes(salt_length)
  end
  def gen_salt(_) do
    raise ArgumentError, "The salt is the wrong length."
  end

  @doc """
  Hash the password using pbkdf2_sha512.

  In most cases, you will want to use the `hashpwsalt` function instead.
  Use this function if you want more control over the generation of the
  salt or the number of rounds.
  """
  def hashpass(password, salt, rounds \\ Config.pbkdf2_rounds) do
    if is_binary(salt) do
      pbkdf2(password, salt, rounds, 64) |> format(salt, rounds)
    else
      raise ArgumentError, "Wrong type. The salt needs to be a string."
    end
  end

  @doc """
  Hash the password with a salt which is randomly generated.

  To change the complexity (and the time taken) of the  password hash
  calculation, you need to change the value for `pbkdf2_rounds`
  in the config file.
  """
  def hashpwsalt(password) do
    hashpass(password, gen_salt(), Config.pbkdf2_rounds)
  end

  defp format(hash, salt, rounds) do
    "$pbkdf2-sha512$#{rounds}$#{Base64.encode(salt)}$#{Base64.encode(hash)}"
  end

  @doc """
  Check the password.

  The check is performed in constant time to avoid timing attacks.
  """
  def checkpw(password, hash) when is_binary(password) and is_binary(hash) do
    [_, _, rounds, salt, hash] = String.split(hash, "$")
    pbkdf2(password, Base64.decode(salt), String.to_integer(rounds), 64)
    |> Base64.encode
    |> Tools.secure_check(hash)
  end
  def checkpw(_password, _hash) do
    raise ArgumentError, "Wrong type. The password and hash need to be strings."
  end

  @doc """
  Perform a dummy check for a user that does not exist.

  This always returns false. The reason for implementing this check is
  in order to make user enumeration by timing responses more difficult.
  """
  @dialyzer({:nowarn_function, dummy_checkpw: 0})
  def dummy_checkpw do
    hashpwsalt("password")
    false
  end

  defp pbkdf2(password, salt, rounds, length) when byte_size(salt) in 16..1024 do
    pbkdf2(password, salt, rounds, length, 1, [], 0)
  end
  defp pbkdf2(_password, _salt, _rounds, _length) do
    raise ArgumentError, "The salt is the wrong length."
  end

  defp pbkdf2(_password, _salt, _rounds, max_length, _block_index, acc, length)
  when length >= max_length do
    key = acc |> Enum.reverse |> IO.iodata_to_binary
    <<bin::binary-size(max_length), _::binary>> = key
    bin
  end
  defp pbkdf2(password, salt, rounds, max_length, block_index, acc, length) do
    initial = :crypto.hmac(:sha512, password, <<salt::binary, block_index::integer-size(32)>>)
    block = iterate(password, rounds - 1, initial, initial)
    pbkdf2(password, salt, rounds, max_length, block_index + 1,
    [block | acc], byte_size(block) + length)
  end

  defp iterate(_password, 0, _prev, acc), do: acc
  defp iterate(password, round, prev, acc) do
    next = :crypto.hmac(:sha512, password, prev)
    iterate(password, round - 1, next, :crypto.exor(next, acc))
  end
end
