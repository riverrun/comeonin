defmodule Pbkdf2Sha512 do
  @moduledoc """
  """

  use Bitwise
  @max_length bsl(1, 32) - 1

  def gen_salt() do
  end

  def hashpass(password, salt) do
    pbkdf2 |> finish
  end

  def hashpwsalt(password) do
    salt = gen_salt()
    hashpass(password, salt)
  end

  def checkpw(password, hash) do
  end

  def dummy_checkpw() do
  end

  def finish() do
  end

  def pbkdf2(password, salt, iterations \\ 1000, length \\ 32) do
    if length > @max_length do
      raise ArgumentError, "length must be less than or equal to #{@max_length}"
    else
      pbkdf2(password, salt, iterations, length, 1, [], 0)
    end
  end

  defp pbkdf2(_password, _salt, _iterations, max_length, _block_index, acc, length)
      when length >= max_length do
    key = acc |> Enum.reverse |> IO.iodata_to_binary
    <<bin::binary-size(max_length), _::binary>> = key
    bin
  end
  defp pbkdf2(password, salt, iterations, max_length, block_index, acc, length) do
    initial = :crypto.hmac(:sha512, password, <<salt::binary, block_index::integer-size(32)>>)
    block = iterate(password, iterations - 1, initial, initial)
    pbkdf2(password, salt, iterations, max_length, block_index + 1,
             [block | acc], byte_size(block) + length)
  end

  defp iterate(_password, 0, _prev, acc), do: acc
  defp iterate(password, iteration, prev, acc) do
    next = :crypto.hmac(:sha512, password, prev)
    iterate(password, iteration - 1, next, :crypto.exor(next, acc))
  end
end
