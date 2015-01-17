defmodule Comeonin.Base64 do
  import Bitwise

  @moduledoc """
  Similar to standard base64 encoding and decoding, but
  using `.` instead of `+` and with no padding.
  """

  b64_alphabet    = Enum.with_index 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789./'

  for {encoding, value} <- b64_alphabet do
    defp unquote(:enc64)(unquote(value)), do: unquote(encoding)
    defp unquote(:dec64)(unquote(encoding)), do: unquote(value)
  end

  defp do_encode64(<<>>, _), do: <<>>
  defp do_encode64(data, enc) do
    split =  3 * div(byte_size(data), 3)
    <<main::size(split)-binary, rest::binary>> = data
    main = for <<c::6 <- main>>, into: <<>>, do: <<enc.(c)::8>>
    case rest do
      <<c1::6, c2::6, c3::4>> ->
        <<main::binary, enc.(c1)::8, enc.(c2)::8, enc.(bsl(c3, 2))::8, ?=>>
      <<c1::6, c2::2>> ->
        <<main::binary, enc.(c1)::8, enc.(bsl(c2, 4))::8, ?=, ?=>>
      <<>> ->
        main
    end
  end

  defp do_decode64(<<>>, _), do: <<>>
  defp do_decode64(string, dec) when rem(byte_size(string), 4) == 0 do
    split = byte_size(string) - 4
    <<main::size(split)-binary, rest::binary>> = string
    main = for <<c::8 <- main>>, into: <<>>, do: <<dec.(c)::6>>
    case rest do
      <<c1::8, c2::8, ?=, ?=>> ->
        <<main::binary, dec.(c1)::6, bsr(dec.(c2), 4)::2>>
      <<c1::8, c2::8, c3::8, ?=>> ->
        <<main::binary, dec.(c1)::6, dec.(c2)::6, bsr(dec.(c3), 2)::4>>
      <<c1::8, c2::8, c3::8, c4::8>> ->
        <<main::binary, dec.(c1)::6, dec.(c2)::6, dec.(c3)::6, dec.(c4)::6>>
      <<>> ->
        main
    end
  end
  defp do_decode64(_, _) do
    raise ArgumentError, "incorrect padding"
  end
