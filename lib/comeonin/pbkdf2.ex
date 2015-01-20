defmodule Comeonin.Pbkdf2 do
  @moduledoc """
  Info about pbkdf and reasons for choosing sha512.
  """

  use Bitwise
  alias Comeonin.Tools

  @max_length bsl(1, 32) - 1

  @doc """
  Generate a salt for use with the `hashpass` and
  `hashpwsalt` functions.
  """
  def gen_salt(salt_length \\ 16) do
    :crypto.rand_bytes(salt_length)
  end

  @doc """
  Hash the password using pbkdf2_sha512.
  """
  def hashpass(password, salt, rounds \\ 20000, length \\ 64) do
    pbkdf2(password, salt, rounds, length) |> format(salt, rounds)
  end

  @doc """
  Hash the password with a salt which is randomly generated.
  """
  def hashpwsalt(password, salt_length \\ 16, rounds \\ 20000, length \\ 64) do
    salt = gen_salt(salt_length)
    hashpass(password, salt, rounds, length)
  end

  defp format(hash, salt, rounds) do
    "$pbkdf2-sha512$#{rounds}$#{salt |> Tools.encode64}$#{hash |> Tools.encode64}"
  end

  @doc """
  Check the password.

  The check is performed in constant time to avoid timing attacks.
  """
  def checkpw(password, hash) do
    [_, _, rounds, salt, hash] = String.split(hash, "$")
    pbkdf2(password, Tools.decode64(salt), String.to_integer(rounds), 64)
    |> Tools.encode64
    |> String.to_char_list
    |> Tools.secure_check(String.to_char_list(hash))
  end

  @doc """
  Perform a dummy check for a user that does not exist.
  This always returns false. The reason for implementing this check is
  in order to make user enumeration by timing responses more difficult.
  """
  def dummy_checkpw do
    checkpw("password", "$pbkdf2-sha512$4096$c2FsdA$0Zexsz2wFD4BixLz0dFHnmzevcyXxcD4f2kC4HL0V7UUPzBgJkGz1VzTNZiMs2uEN2Bg7NUy4Dm3QqI5Q0ry1Q")
    false
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
