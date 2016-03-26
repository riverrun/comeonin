defmodule Comeonin.OtpTest do
  use ExUnit.Case, async: false

  alias Comeonin.Otp

  def get_count do
    {megasecs, secs, _} = :os.timestamp()
    trunc((megasecs * 1000000 + secs) / 30)
  end

  test "generate secret with correct input" do
    assert Otp.gen_secret() |> byte_size == 32
    assert Otp.gen_secret(16) |> byte_size == 16
    assert Otp.gen_secret(24) |> byte_size == 24
    assert Otp.gen_secret(32) |> byte_size == 32
  end

  test "error when generating secret with the wrong length" do
    for i <- [10, 20, 30, 40] do
      assert_raise ArgumentError, "Invalid length", fn ->
        Otp.gen_secret(i)
      end
    end
  end

  test "valid otp token" do
    refute Otp.valid_token("12345", 5)
    assert Otp.valid_token("123456", 6)
    refute Otp.valid_token("123456", 8)
    assert Otp.valid_token("12345678", 8)
  end

  test "generate hotp" do
    assert Otp.gen_hotp("MFRGGZDFMZTWQ2LK", 1) == "765705"
    assert Otp.gen_hotp("MFRGGZDFMZTWQ2LK", 2) == "816065"
    assert Otp.gen_hotp("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ", 5) == "254676"
    assert Otp.gen_hotp("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ", 8) == "399871"
  end

  test "generate hotp with zero padding" do
    assert Otp.gen_hotp("MFRGGZDFMZTWQ2LK", 19) == "088239"
  end

  test "check hotp" do
    assert Otp.check_hotp("816065", "MFRGGZDFMZTWQ2LK") == 2
    assert Otp.check_hotp("088239", "MFRGGZDFMZTWQ2LK", last: 18) == 19
    assert Otp.check_hotp("287922", "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ", last: 5) == 6
  end

  test "check hotp fails for outside window" do
    refute Otp.check_hotp("088239", "MFRGGZDFMZTWQ2LK", last: 10)
    refute Otp.check_hotp("287922", "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ", last: 4, window: 0)
    refute Otp.check_hotp("287922", "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ", last: 3, window: 1)
  end

  test "check totp" do
    assert Otp.gen_totp("MFRGGZDFMZTWQ2LK") |> Otp.check_totp("MFRGGZDFMZTWQ2LK")
    assert Otp.gen_totp("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ")
    |> Otp.check_totp("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ")
  end

  test "check totp fails for outside window" do
    token = Otp.gen_hotp("MFRGGZDFMZTWQ2LK", get_count() - 2)
    refute Otp.check_totp(token, "MFRGGZDFMZTWQ2LK")
    token = Otp.gen_hotp("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ", get_count() + 2)
    refute Otp.check_totp(token, "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ")
  end

end
