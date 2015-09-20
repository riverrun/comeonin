defmodule Comeonin.PasswordStrength.Substitutions do
  @moduledoc """
  A submodule of the `Comeonin.PasswordStrength` module.

  This module has functions to make standard substitutions when checking
  if the password, or a similar password, is in the common passwords list.

  There are also checks on the password with the first letter removed,
  the last letter removed, and both the first and last letters removed.

  ## Substitutions

  """

  @sub_dict %{"a" => ["a", "@", "4"], "b" => ["b", "8"], "c" => ["c", "[", "("],
    "d" => ["d"], "e" => ["e", "3"], "f" => ["f"], "g" => ["g", "6", "9"],
    "h" => ["h","#"], "i" => ["i", "1", "!"], "j" => ["j"], "k" => ["k"],
    "l" => ["l", "!", "1"], "m" => ["m"], "n" => ["n"], "o" => ["o", "0"],
    "p" => ["p"], "q" => ["q"], "r" => ["r"], "s" => ["s", "$", "5"],
    "t" => ["t", "+", "7"], "u" => ["u", "v"], "v" => ["v", "u"], "w" => ["w"],
    "x" => ["x", "+"], "y" => ["y"], "z" => ["z", "2"],
    "0" => ["0", "o", ")"], "1" => ["1", "!", "i", "l"], "2" => ["2", "@", "z"],
    "3" => ["3", "#", "e"], "4" => ["4", "$", "a"], "5" => ["5", "%", "s"],
    "6" => ["6", "^", "g"], "7" => ["7", "&", "t"], "8" => ["8", "*", "b"],
    "9" => ["9", "(", "g"], "!" => ["!", "1"], "@" => ["@", "a"],
    "#" => ["#", "h", "3"], "$" => ["$", "s", "4"], "%" => ["%", "5"],
    "^" => ["^", "6"], "&" => ["&", "7"], "*" => ["*", "8"], "(" => ["(", "c", "9"],
    "[" => ["[", "c"], "+" => ["+", "x", "t"]}

  @doc """
  """
  def all_candidates(password) do
    word = String.downcase(password)
    len = String.length(word)
    cands = [word, :binary.part(word, {1, len - 1}),
      :binary.part(word, {0, len - 1}), :binary.part(word, {1, len - 2})]
    cands ++ Enum.map(cands, &word_candidates/1) |> List.flatten
  end

  defp word_candidates(password) do
    for i <- password |> word_subs |> product, do: Enum.join(i)
  end

  defp word_subs(word) do
    for <<letter <- word>>, do: Map.get(@sub_dict, <<letter>>, [<<letter>>])
  end

  defp product([h]), do: (for i <- h, do: [i])
  defp product([h|t]) do
    for i <- h, j <- product(t), do: [i|j]
  end

end
