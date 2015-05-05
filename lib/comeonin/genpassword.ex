defmodule Comeonin.Genpassword do
  @moduledoc """
  Module to generate random passwords.
  """

  @doc """
  """
  def gen_password(len \\ 8) do
    case rand_numbers(len) |> pass_check do
      false -> gen_password(len)
      code -> for val <- code, do: get_char(val)
    end
  end

  defp rand_numbers(len) do
    for _ <- 1..len, do: :crypto.rand_uniform(0, 75)
  end

  defp get_char(val) do
    elem({?., ?/, ?!, ?@, ?#, ?$, ?%, ?^, ?*, ?(, ?), ?;, ?:,
      ?A, ?B, ?C, ?D, ?E, ?F, ?G, ?H, ?I, ?J, ?K, ?L,
      ?M, ?N, ?O, ?P, ?Q, ?R, ?S, ?T, ?U, ?V, ?W, ?X,
      ?Y, ?Z, ?a, ?b, ?c, ?d, ?e, ?f, ?g, ?h, ?i, ?j, ?k, ?l,
      ?m, ?n, ?o, ?p, ?q, ?r, ?s, ?t, ?u, ?v, ?w, ?x,
      ?y, ?z, ?0, ?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9}, val)
  end

  defp pass_check(code) do
    Enum.any?(code, &(&1 < 13)) and Enum.any?(code, &(&1 > 64)) and code
  end
end
