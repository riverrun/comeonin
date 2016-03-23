defmodule Comeonin.TwoFa do
  @moduledoc """
  """

  use Bitwise

  def valid_token(token, token_length) do
    token_length == byte_size(token) and
    Regex.match?(~r/^[0-9]+$/, token)
  end

  def gen_hotp(secret, count, opts \\ []) do
    token_length = Keyword.get(opts, :token_length, 6)
    hash = :crypto.hmac(:sha, Base.decode32!(secret, padding: false),
                        <<count :: size(8)-big-unsigned-integer-unit(8)>>)
    offset = :binary.at(hash, 19) &&& 15
    <<truncated :: size(4)-integer-unit(8)>> = :binary.part(hash, offset, 4)
    (truncated &&& 0x7fffffff)
    |> rem(trunc(:math.pow(10, token_length)))
    |> :erlang.integer_to_binary
    |> String.rjust(token_length, ?0)
  end

  def gen_totp(secret, opts) do
    gen_hotp(secret, interval_count(Keyword.get(opts, :interval_length, 30)), opts)
  end

  def check_hotp(token, secret, opts \\ []) do
    case valid_token(token, Keyword.get(opts, :token_length, 6)) do
      true ->
        {last, tries} = {Keyword.get(opts, :last, 0), Keyword.get(opts, :tries, 5)}
        check_token(token, secret, last + 1, last + tries + 1, opts)
      _ -> false
    end
  end

  def check_totp(token, secret, opts \\ []) do
    case valid_token(token, Keyword.get(opts, :token_length, 6)) do
      true ->
        {count, window} = {interval_count(Keyword.get(opts, :interval_length, 30)),
                           Keyword.get(opts, :window, 5)}
        check_token(token, secret, count - window, count + window, opts)
      _ -> false
    end
  end

  def interval_count(interval_length) do
    {megasecs, secs, _} = :os.timestamp()
    trunc((megasecs * 1000000 + secs) / interval_length)
  end

  def check_token(_token, _secret, current, last, _opts) when current == last do
    false
  end
  def check_token(token, secret, current, last, opts) do
    case gen_hotp(secret, current, opts) do
      ^token -> current
      _ -> check_token(token, secret, current + 1, last, opts)
    end
  end
end
