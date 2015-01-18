defmodule Comeonin.Pbkdf2 do
  @moduledoc """
  Info about pbkdf and reasons for choosing sha512.
  """

  use Bitwise
  alias Comeonin.Base64

  @max_length bsl(1, 32) - 1

  @doc """
  Generate a salt for use with the `hashpass` and
  `hashpwsalt` functions.
  """
  def gen_salt(salt_length \\ 16) do
    :crypto.rand_bytes(salt_length) |> Base64.encode
  end

  @doc """
  Hash the password using pbkdf2_sha512.
  """
  def hashpass(password, salt, rounds \\ 1000, length \\ 64) do
    pbkdf2(password, salt, rounds, length) |> finish(salt, rounds)
  end

  @doc """
  Hash the password with a salt which is randomly generated.
  """
  def hashpwsalt(password) do
    salt = gen_salt()
    hashpass(password, salt)
  end

  @doc """
  Check the password.

  The check is performed in constant time to avoid timing attacks.
  """
  def checkpw(password, hash) do
    {_, _, rounds, salt, hash} = String.split(hash, "$")
    pbkdf2(password, salt, rounds, 64) |> Tools.secure_check(hash)
    #hashpass(password, salt, rounds) |> Tools.secure_check(hash)
  end

  @doc """
  Perform a dummy check for a user that does not exist.
  This always returns false. The reason for implementing this check is
  in order to make user enumeration by timing responses more difficult.
  """
  def dummy_checkpw do
    false
  end

  defp finish(hash, salt, rounds) do
    "$pbkdf2-sha512$#{rounds}$#{salt}$#{hash |> Base64.encode}"
  end

  defp pbkdf2(password, salt, rounds, length) do
    if length > @max_length do
      raise ArgumentError, "length must be less than or equal to #{@max_length}"
    else
      pbkdf2(password, salt, rounds, length, 1, [], 0)
    end
  end

  defp pbkdf2(_password, _salt, _rounds, max_length, _block_index, acc, length)
      when length >= max_length do
    key = acc |> Enum.reverse |> IO.inspect |> IO.iodata_to_binary
    <<bin::binary-size(max_length), _::binary>> = key
    bin
  end
  defp pbkdf2(password, salt, rounds, max_length, block_index, acc, length) do
    initial = :crypto.hmac(:sha512, password, <<salt::binary, block_index::integer-size(64)>>)
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
