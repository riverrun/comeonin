defmodule Comeonin.Password.Tools do

  def get_words do
    Path.join(__DIR__, "10k_6chars.txt")
    |> File.read! |> String.split("\n") |> create_map
  end

  def any?([h|t], fun) do
    if fun.(h), do: h, else: any?(t, fun)
  end
  def any?([], _), do: false

  defp create_map(wordlist) do
    Enum.reduce(wordlist, %{}, fn word, acc -> update_map(acc, word) end)
  end

  defp update_map(map, word) do
    {k, v} = String.split_at(word, 4)
    case Map.fetch(map, k) do
      {:ok, val} -> Map.put(map, k, val ++ [v])
      :error -> Map.put(map, k, [v])
    end
  end

end
