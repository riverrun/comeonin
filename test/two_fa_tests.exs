defmodule Comeonin.TwoFaTest do
  use ExUnit.Case, async: false

  alias Comeonin.TwoFa

  test "valid otp token" do
    #assert TwoFa.valid_token(123456, 6) # check type? allow integer?
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

  test "check hotp fails for too small window" do
    refute TwoFa.check_hotp("088239", "MFRGGZDFMZTWQ2LK", last: 10)
    refute TwoFa.check_hotp("287922", "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ", last: 4, tries: 1)
  end

end
