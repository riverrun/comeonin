defmodule Comeonin.Bcrypt.Base64 do
  @moduledoc """
  Module that provides base64 encoding for bcrypt.

  Bcrypt uses an adapted base64 alphabet (using `.` instead of `+`,
  starting with `./` and with no padding).
  """

  use Bitwise

  @decode_map {:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:ws,:ws,:bad,:bad,:ws,:bad,:bad,
    :bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,
    :ws,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,0,1,
    54,55,56,57,58,59,60,61,62,63,:bad,:bad,:bad,:eq,:bad,:bad,
    :bad,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,
    17,18,19,20,21,22,23,24,25,26,27,:bad,:bad,:bad,:bad,:bad,
    :bad,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,
    43,44,45,46,47,48,49,50,51,52,53,:bad,:bad,:bad,:bad,:bad,
    :bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,
    :bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,
    :bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,
    :bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,
    :bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,
    :bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,
    :bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,
    :bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad,:bad}

  @doc """
  Encode using the adapted Bcrypt alphabet.

  ## Examples

      iex> Comeonin.Bcrypt.Base64.encode 'spamandeggs'
      'a1/fZUDsXETlX1K'
  """
  def encode(words), do: encode_l(words)

  @doc """
  Decode using the adapted Bcrypt alphabet.

  ## Examples

      iex> Comeonin.Bcrypt.Base64.decode 'a1/fZUDsXETlX1K'
      'spamandeggs'
  """
  def decode(words), do: decode_l(words, [])

  @doc """
  """
  def normalize(salt) do
    decode(salt) |> encode
  end

  defp b64e(val) do
    elem({?., ?/, ?A, ?B, ?C, ?D, ?E, ?F, ?G, ?H, ?I, ?J, ?K, ?L,
      ?M, ?N, ?O, ?P, ?Q, ?R, ?S, ?T, ?U, ?V, ?W, ?X,
      ?Y, ?Z, ?a, ?b, ?c, ?d, ?e, ?f, ?g, ?h, ?i, ?j, ?k, ?l,
      ?m, ?n, ?o, ?p, ?q, ?r, ?s, ?t, ?u, ?v, ?w, ?x,
      ?y, ?z, ?0, ?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9}, val)
  end

  defp encode_l([]), do: []
  defp encode_l([a]) do
    [b64e(a >>> 2),
      b64e((a &&& 3) <<< 4)]
  end
  defp encode_l([a,b]) do
    [b64e(a >>> 2),
      b64e(((a &&& 3) <<< 4) ||| (b >>> 4)),
      b64e((b &&& 15) <<< 2)]
  end
  defp encode_l([a,b,c|ls]) do
    bb = (a <<< 16) ||| (b <<< 8) ||| c
    [b64e(bb >>> 18),
      b64e((bb >>> 12) &&& 63),
      b64e((bb >>> 6) &&& 63),
      b64e(bb &&& 63) | encode_l(ls)]
  end

  defp decode_l([], a), do: a
  defp decode_l([c1,c2], a) do
    bits2x6 = (b64d(c1) <<< 18) ||| (b64d(c2) <<< 12)
    octet1 = bits2x6 >>> 16
    a ++ [octet1]
  end
  defp decode_l([c1,c2,c3], a) do
    bits3x6 = (b64d(c1) <<< 18) ||| (b64d(c2) <<< 12) ||| (b64d(c3) <<< 6)
    octet1 = bits3x6 >>> 16
    octet2 = (bits3x6 >>> 8) &&& 0xff
    a ++ [octet1,octet2]
  end
  defp decode_l([c1,c2,c3,c4| cs], a) do
    bits4x6 = (b64d(c1) <<< 18) ||| (b64d(c2) <<< 12) ||| (b64d(c3) <<< 6) ||| b64d(c4)
    octet1 = bits4x6 >>> 16
    octet2 = (bits4x6 >>> 8) &&& 0xff
    octet3 = bits4x6 &&& 0xff
    decode_l(cs, a ++ [octet1,octet2,octet3])
  end

  defp b64d(val) do
    b64d_ok(elem(@decode_map, val))
  end

  defp b64d_ok(val) when is_integer(val), do: val
  defp b64d_ok(val) do
    raise ArgumentError, "Invalid character: #{val}"
  end
end
