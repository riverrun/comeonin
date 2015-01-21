defmodule Comeonin.Tools do
  @moduledoc """
  Module that provides various tools for the hashing algorithms.
  """

  import Bitwise

  b64_alphabet = Enum.with_index 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789./'

  for {encoding, value} <- b64_alphabet do
    defp unquote(:enc64)(unquote(value)), do: unquote(encoding)
    defp unquote(:dec64)(unquote(encoding)), do: unquote(value)
  end

  @doc """
  Encode using an adapted base64 alphabet (using `.`
  instead of `+` and with no padding.

  ## Examples

      iex> Comeonin.Tools.encode64("foobar")
      "Zm9vYmFy"

      iex> Comeonin.Tools.encode64 "spamandeggs"
      "c3BhbWFuZGVnZ3M"
  """
  def encode64(<<>>), do: <<>>
  def encode64(data) do
    split =  3 * div(byte_size(data), 3)
    <<main::size(split)-binary, rest::binary>> = data
    main = for <<c::6 <- main>>, into: <<>>, do: <<enc64(c)::8>>
    case rest do
      <<c1::6, c2::6, c3::4>> ->
        <<main::binary, enc64(c1)::8, enc64(c2)::8, enc64(bsl(c3, 2))::8>>
      <<c1::6, c2::2>> ->
        <<main::binary, enc64(c1)::8, enc64(bsl(c2, 4))::8>>
      <<>> ->
        main
    end
  end

  @doc """
  Decode using an adapted base64 alphabet (using `.`
  instead of `+` and with no padding.

  ## Examples

      iex> Comeonin.Tools.decode64("Zm9vYmFy")
      "foobar"

      iex> Comeonin.Tools.decode64("c3BhbWFuZGVnZ3M")
      "spamandeggs"
  """
  def decode64(<<>>), do: <<>>
  def decode64(data) do
    split =  4 * div(byte_size(data), 4)
    <<main::size(split)-binary, rest::binary>> = data
    main = for <<c::8 <- main>>, into: <<>>, do: <<dec64(c)::6>>
    case rest do
      <<c1::8, c2::8>> ->
        <<main::binary, dec64(c1)::6, bsr(dec64(c2), 4)::2>>
      <<c1::8, c2::8, c3::8>> ->
        <<main::binary, dec64(c1)::6, dec64(c2)::6, bsr(dec64(c3), 2)::4>>
      <<>> ->
        main
    end
  end

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
    secure_check(hs, ss, acc ||| (h ^^^ s))
  end
  defp secure_check([], [], acc) do
    acc
  end
end
