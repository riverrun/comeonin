defmodule Comeonin.PasswordStrength.Substitutions do
  @moduledoc """
  """

  toletter = [{"@", "a"}, {"4", "a"}, {"8", "b"}, {"[", "c"}, {"(", "c"}, {"3", "e"},
      {"6", "g"}, {"9", "g"}, {"#", "h"}, {"!", "i"}, {"1", "i"}, {"|", "l"},
      {"0", "o"}, {"$", "s"}, {"5", "s"}, {"+", "t"}, {"7", "t"}, {"2", "z"}]

  todigit = [{"o", "0"}, {"i", "1"}, {"l", "1"}, {"z", "2"}, {"e", "3"}, {"a", "4"},
      {"s", "5"}, {"g", "6"}, {"t", "7"}, {"b", "8"}]

  for {value, substitution} <- toletter do
    defp get_letter(unquote(value)), do: unquote(substitution)
  end

  for {value, substitution} <- todigit do
    defp get_digit(unquote(value)), do: unquote(substitution)
  end

  @letters ["a", "b", "c", "e", "g", "h", "i", "l", "o", "s", "t", "z"]
  @digits ["@", "4", "8", "[", "(", "3", "6", "9", "#", "!", "1", "0",
      "$", "5", "+", "7", "2"]

  def get_candidates(password) do
    len = String.length(password) - 1
    cands = [password, :binary.part(password, {1, len}), :binary.part(password, {0, len})]
    cands ++ Enum.map(cands, &letter_word/1) ++ Enum.map(cands, &digit_word/1)
  end

  defp letter_word(password) do
    for <<c <- password>>, into: "", do: digit_to_letter(<<c>>)
  end

  defp digit_word(password) do
    for <<c <- password>>, into: "", do: letter_to_digit(<<c>>)
  end

  defp digit_to_letter(digit) do
    if digit in @digits, do: get_letter(digit), else: digit
  end

  defp letter_to_digit(letter) do
    if letter in @letters, do: get_digit(letter), else: letter
  end

end
