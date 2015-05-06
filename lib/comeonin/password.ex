defmodule Comeonin.Password do
  @moduledoc """
  Module to generate random passwords and validate passwords
  for extra characters.
  """

  @alphabet ',./!@#$%^&*();:?<>ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
  @digits ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
  @punc [",", ".", "/", "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", ";", ":", "?", "<", ">"]

  @char_map Enum.map_reduce(@alphabet, 0, fn x, acc -> {{acc, x}, acc + 1} end)
  |> elem(0) |> Enum.into(%{})

  @doc """
  """
  def gen_password(len \\ 8) do
    case rand_numbers(len) |> pass_check do
      false -> gen_password(len)
      code -> for val <- code, do: Map.get(@char_map, val)
    end
  end
  defp rand_numbers(len) do
    for _ <- 1..len, do: :crypto.rand_uniform(0, 80)
  end
  defp pass_check(code) do
    Enum.any?(code, &(&1 < 18)) and Enum.any?(code, &(&1 > 69)) and code
  end

  @doc """
  """
  def valid_password?(password) do
    has_punc_digit?(password, @digits, @punc) and password
  end
  defp has_punc_digit?(word, digits, punc) do
    :binary.match(word, digits) != :nomatch and :binary.match(word, punc) != :nomatch
  end
end
