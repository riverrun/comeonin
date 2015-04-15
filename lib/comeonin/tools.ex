defmodule Comeonin.Tools do
  @moduledoc """
  Module that provides various tools for the hashing algorithms.
  """

  import Bitwise

  b64_alphabet = Enum.with_index 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789./'
  bcrypt_b64_alphabet = Enum.with_index './ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'

  Enum.each [ {:enc64,    :dec64,    b64_alphabet},
              {:enc64bcrypt, :dec64bcrypt, bcrypt_b64_alphabet} ], fn({enc, dec, alphabet}) ->
    for {encoding, value} <- alphabet do
      defp unquote(enc)(unquote(value)), do: unquote(encoding)
      defp unquote(dec)(unquote(encoding)), do: unquote(value)
    end
    defp unquote(dec)(c) do
      raise ArgumentError, "non-alphabet digit found: #{<<c>>}"
    end
  end

  @doc """
  Encode using an adapted base64 alphabet (using `.`
  instead of `+` and with no padding).

  ## Examples

      iex> Comeonin.Tools.base64enc "spamandeggs"
      "c3BhbWFuZGVnZ3M"
  """
  def base64enc(data) when is_binary(data) do
    encode64(data, &enc64/1)
  end

  @doc """
  Decode using an adapted base64 alphabet (using `.`
  instead of `+` and with no padding).

  ## Examples

      iex> Comeonin.Tools.base64dec "c3BhbWFuZGVnZ3M"
      "spamandeggs"
  """
  def base64dec(string) when is_binary(string) do
    decode64(string, &dec64/1)
  end

  @doc """
  Encode using a base64 alphabet adapted for bcrypt.

  ## Examples

      iex> Comeonin.Tools.bcrypt64enc "spamandeggs"
      "a1/fZUDsXETlX1K"
  """
  def bcrypt64enc(data) when is_binary(data) do
    encode64(data, &enc64bcrypt/1)
  end

  @doc """
  Decode using a base64 alphabet adapted for bcrypt.

  ## Examples

      iex> Comeonin.Tools.bcrypt64dec "a1/fZUDsXETlX1K"
      "spamandeggs"
  """
  def bcrypt64dec(string) when is_binary(string) do
    decode64(string, &dec64bcrypt/1)
  end

  defp encode64(<<>>, _), do: <<>>
  defp encode64(data, enc) do
    split =  3 * div(byte_size(data), 3)
    <<main::size(split)-binary, rest::binary>> = data
    main = for <<c::6 <- main>>, into: <<>>, do: <<enc.(c)::8>>
    case rest do
      <<c1::6, c2::6, c3::4>> ->
        <<main::binary, enc.(c1)::8, enc.(c2)::8, enc.(bsl(c3, 2))::8>>
      <<c1::6, c2::2>> ->
        <<main::binary, enc.(c1)::8, enc.(bsl(c2, 4))::8>>
      <<>> ->
        main
    end
  end

  defp decode64(<<>>, _), do: <<>>
  defp decode64(data, dec) do
    split =  4 * div(byte_size(data), 4)
    <<main::size(split)-binary, rest::binary>> = data
    main = for <<c::8 <- main>>, into: <<>>, do: <<dec.(c)::6>>
    case rest do
      <<c1::8, c2::8>> ->
        <<main::binary, dec.(c1)::6, bsr(dec.(c2), 4)::2>>
      <<c1::8, c2::8, c3::8>> ->
        <<main::binary, dec.(c1)::6, dec.(c2)::6, bsr(dec.(c3), 2)::4>>
      <<>> ->
        main
    end
  end

  @doc """
  Compares the two binaries in constant time to avoid timing attacks.
  """
  def secure_check(hash, stored) when is_binary(hash) and is_binary(stored) do
    secure_check(:erlang.binary_to_list(hash), :erlang.binary_to_list(stored))
  end
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
