defmodule Comeonin.TwoFaTest do
  use ExUnit.Case, async: false

  alias Comeonin.TwoFa

  test "generate secret with correct input" do
    assert TwoFa.gen_secret() |> byte_size == 32
    assert TwoFa.gen_secret(16) |> byte_size == 16
    assert TwoFa.gen_secret(24) |> byte_size == 24
    assert TwoFa.gen_secret(32) |> byte_size == 32
  end

  test "error when generating secret with the wrong length" do
    assert_raise ArgumentError, "Invalid length", fn ->
      TwoFa.gen_secret(20)
    end
  end

  test "valid otp token" do
    refute TwoFa.valid_token("12345", 5)
    assert TwoFa.valid_token("123456", 6)
    refute TwoFa.valid_token("123456", 8)
    assert TwoFa.valid_token("12345678", 8)
  end

  test "generate hotp" do
    assert TwoFa.gen_hotp("MFRGGZDFMZTWQ2LK", 1) == "765705"
    assert TwoFa.gen_hotp("MFRGGZDFMZTWQ2LK", 2) == "816065"
    assert TwoFa.gen_hotp("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ", 5) == "254676"
    assert TwoFa.gen_hotp("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ", 8) == "399871"
  end

  test "generate hotp with zero padding" do
    assert TwoFa.gen_hotp("MFRGGZDFMZTWQ2LK", 19) == "088239"
  end

  test "check hotp" do
    assert TwoFa.check_hotp("816065", "MFRGGZDFMZTWQ2LK") == 2
    assert TwoFa.check_hotp("088239", "MFRGGZDFMZTWQ2LK", last: 18) == 19
    assert TwoFa.check_hotp("287922", "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ", last: 5) == 6
  end

  test "check hotp fails for outside window" do
    refute TwoFa.check_hotp("088239", "MFRGGZDFMZTWQ2LK", last: 10)
    refute TwoFa.check_hotp("287922", "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ", last: 4, window: 0)
    refute TwoFa.check_hotp("287922", "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ", last: 3, window: 1)
  end

  test "check totp" do
    assert TwoFa.gen_totp("MFRGGZDFMZTWQ2LK") |> TwoFa.check_totp("MFRGGZDFMZTWQ2LK")
    assert TwoFa.gen_totp("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ")
    |> TwoFa.check_totp("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ")
  end

end
