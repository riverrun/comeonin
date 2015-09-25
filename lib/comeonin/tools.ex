defmodule Comeonin.Tools do
  @moduledoc """
  Module that provides various tools for the hashing algorithms.
  """

  use Bitwise
  import Comeonin.PasswordStrength

  @alpha Enum.concat ?A..?Z, ?a..?z
  @alphabet '!#$%&\'()*+,-./:;<=>?@[\\]^_{|}~"' ++ @alpha ++ '0123456789'
  @char_map Enum.map_reduce(@alphabet, 0, fn x, acc ->
    {{acc, x}, acc + 1} end)
    |> elem(0) |> Enum.into(%{})

  @doc """
  Randomly generate a password.

  Users are often advised to use random passwords for authentication.
  However, creating truly random passwords is difficult for people to
  do well and is something that computers are usually better at.

  The default length of the password is 12 characters, and it is guaranteed
  to contain at least one digit and one punctuation character.
  """
  def gen_password(len \\ 12) do
    rand_password(len) |> to_string |> ensure_strong(len)
  end

  defp rand_password(len) do
    case rand_numbers(len) |> pass_check do
      false -> rand_password(len)
      code -> for val <- code, do: Map.get(@char_map, val)
    end
  end
  defp rand_numbers(len) do
    for _ <- 1..len, do: :crypto.rand_uniform(0, 93)
  end
  defp pass_check(code) do
    Enum.any?(code, &(&1 < 31)) and Enum.any?(code, &(&1 > 82)) and code
  end

  defp ensure_strong(password, len) do
    case strong_password?(password) do
      true -> password
      _ -> gen_password(len)
    end
  end

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
