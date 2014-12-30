defmodule Comeonin.Tools do
  @moduledoc """
  Module that provides tools for the various hashing algorithms.
  """

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
