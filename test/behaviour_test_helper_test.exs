defmodule Comeonin.BehaviourTestHelperTest do
  use ExUnit.Case

  import Comeonin.BehaviourTestHelper

  test "implementation of Comeonin.PasswordHash behaviour" do
    password = Enum.random(ascii_passwords())
    assert correct_password_true(Comeonin.TestHash, password)
    assert wrong_password_false(Comeonin.TestHash, password)
    refute correct_password_true(Comeonin.FailHash, password)
    refute wrong_password_false(Comeonin.FailHash, password)
  end

  test "Comeonin.PasswordHash behaviour with non-ascii characters" do
    password = Enum.random(non_ascii_passwords())
    assert correct_password_true(Comeonin.TestHash, password)
    assert wrong_password_false(Comeonin.TestHash, password)
    refute correct_password_true(Comeonin.FailHash, password)
    refute wrong_password_false(Comeonin.FailHash, password)
  end

  test "add_hash function" do
    password = Enum.random(ascii_passwords())
    assert add_hash_creates_map(Comeonin.TestHash, password)
  end

  test "check_pass function" do
    password = Enum.random(ascii_passwords())
    assert check_pass_returns_user(Comeonin.TestHash, password)
    assert check_pass_returns_error(Comeonin.TestHash, password)
    refute check_pass_returns_error(Comeonin.FailHash, password)
    assert check_pass_nil_user(Comeonin.TestHash)
  end
end
