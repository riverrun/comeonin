defmodule Comeonin.Password.Common do
  @moduledoc """
  A submodule of the `Comeonin.Password` module.

  This module has functions to check if the password, or a similar password,
  is in the common passwords list.

  There are also checks on the password with the first letter removed,
  the last letter removed, and both the first and last letters removed.

  """

  import Comeonin.Password.Tools

  @common get_words
  @common_keys Map.keys(get_words) |> :sets.from_list

  @sub_dict %{"a" => ["a", "@", "4"], "b" => ["b", "8"],
    "c" => ["c", "[", "("], "d" => ["d"],
    "e" => ["e", "3"], "f" => ["f"],
    "g" => ["g", "6", "9"], "h" => ["h","#"],
    "i" => ["i", "1", "!"], "j" => ["j"],
    "k" => ["k"], "l" => ["l", "!", "1"],
    "m" => ["m"], "n" => ["n"],
    "o" => ["o", "0"], "p" => ["p"],
    "q" => ["q"], "r" => ["r"],
    "s" => ["s", "$", "5"], "t" => ["t", "+", "7"],
    "u" => ["u", "v"], "v" => ["v", "u"],
    "w" => ["w"], "x" => ["x", "+"],
    "y" => ["y"], "z" => ["z", "2"],
    "0" => ["0", "o", ")"], "1" => ["1", "!", "i", "l"],
    "2" => ["2", "@", "z"], "3" => ["3", "#", "e"],
    "4" => ["4", "$", "a"], "5" => ["5", "%", "s"],
    "6" => ["6", "^", "g"], "7" => ["7", "&", "t"],
    "8" => ["8", "*", "b"], "9" => ["9", "(", "g"],
    "!" => ["!", "1"], "@" => ["@", "a"],
    "#" => ["#", "h", "3"], "$" => ["$", "s", "4"],
    "%" => ["%", "5"], "^" => ["^", "6"],
    "&" => ["&", "7"], "*" => ["*", "8"],
    "(" => ["(", "c", "9"], "[" => ["[", "c"],
    "+" => ["+", "x", "t"]}

  @doc """
  Check to see if the passord is too similar to any of the passwords
  in the common password list.

  The password is checked after certain common substitutions have been
  made. It is also checked with the first letter and / or the last letter removed.

  ## Examples

  The password `p@$5W0rD9` would produce these (among other) words,
  which can be checked against a list of common passwords:

      ["p4sswordg", "assword9", "assword", "password",
      "p@s%word", "pas%w0rd9", "a$%w0rd9", "p445w0rd"]

  As can be seen, `p@$5W0rD9` is similar to the very common password `password`,
  and so it is judged to be too weak.
  """
  def common_password?(password, word_len) do
    case {password |> check_start(0), password |> check_start(1)} do
      {false, false} -> false
      {word, false} -> check_rest(password, word, 4, word_len - 4)
      {_, word} -> check_rest(password, word, 5, word_len - 5)
    end
  end

  defp check_start(password, start) do
    get_candidates(password, {start, 4}) |> any?(&:sets.is_element(&1, @common_keys))
  end

  defp check_rest(password, word, start, rest_len) do
    get_candidates(password, {start, rest_len}, {start, rest_len - 1})
    |> Enum.any?(&:lists.member(&1, Map.get(@common, word)))
  end

  defp get_candidates(word, len) do
    :binary.part(word, len) |> word_alternatives |> List.flatten
  end

  defp get_candidates(word, full, shorter) do
    [:binary.part(word, full), :binary.part(word, shorter)]
    |> Enum.map(&word_alternatives/1) |> List.flatten
  end

  defp word_alternatives(password) do
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
