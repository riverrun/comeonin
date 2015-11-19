defmodule Comeonin.Pbkdf2.Base64 do
  @moduledoc """
  Module that provides base64 encoding for pbkdf2.

  Pbkdf2 uses an adapted base64 alphabet (using `.` instead of `+`
  and with no padding).
  """

  import Bitwise

  b64_alphabet = Enum.with_index 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789./'

  for {encoding, value} <- b64_alphabet do
    defp unquote(:enc64)(unquote(value)), do: unquote(encoding)
    defp unquote(:dec64)(unquote(encoding)), do: unquote(value)
  end

  @doc """
  Encode using the adapted Pbkdf2 alphabet.

  ## Examples

      iex> Comeonin.Pbkdf2.Base64.encode "spamandeggs"
      "c3BhbWFuZGVnZ3M"
  """
  def encode(<<>>), do: <<>>
  def encode(data) do
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
  Decode using the adapted Pbkdf2 alphabet.

  ## Examples

      iex> Comeonin.Pbkdf2.Base64.decode("c3BhbWFuZGVnZ3M")
      "spamandeggs"
  """
  def decode(<<>>), do: <<>>
  def decode(data) do
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
end
