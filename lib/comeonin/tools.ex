defmodule Comeonin.Tools do
  @moduledoc """
  Module that provides various tools for the hashing algorithms.
  """

  use Bitwise

  @doc """
  Use erlang's crypto.strong_rand_bytes by default. Falls back to
  crypto.rand_bytes if there is too little entropy for strong_rand_bytes
  to work.
  """
  def random_bytes(number) when is_integer(number) do
    try do
      :crypto.strong_rand_bytes(number)
    rescue
      _error ->
        :crypto.rand_bytes(number)
    end
  end
  def random_bytes(_) do
    raise ArgumentError, message: "Wrong type. You must call this function with an integer."
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
  defp arithmetic_compare(<<x, left :: binary>>, <<y, right :: binary>>, acc) do
    arithmetic_compare(left, right, acc ||| (x ^^^ y))
  end
  defp arithmetic_compare("", "", acc) do
    acc
  end
end
