defmodule Comeonin.Tools do
  @moduledoc """
  Module that provides various tools for the hashing algorithms.
  """

  use Bitwise

  @doc """
  Compares the two binaries in constant time to avoid timing attacks.
  """
  def secure_check(hash, stored) do
    if byte_size(hash) == byte_size(stored) do
      secure_check(hash, stored, 0) == 0
    else
      false
    end
  end
  defp secure_check(<<h, rest_h :: binary>>, <<s, rest_s :: binary>>, acc) do
    secure_check(rest_h, rest_s, acc ||| (h ^^^ s))
  end
  defp secure_check("", "", acc) do
    acc
  end
end
