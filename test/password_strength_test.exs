defmodule Comeonin.PasswordStrengthTest do
  use ExUnit.Case, async: true

  import Comeonin.PasswordStrength

  test "password minimum length config" do
    assert strong_password?("4ghY&j2", [min_length: 6]) == true
    assert strong_password?("4ghY&j2", [min_length: 8]) ==
    "The password should be at least 8 characters long."
  end

  test "password with a digit and a symbol" do
    for id <- ["hfjkshf6hj#", "8auyk kjkjh", "ty3uhi@ksd"] do
      assert strong_password?(id) == true
    end
  end

  test "password with no digit or symbol" do
    for id <- ["hfjkshfhj", "auykkjkjh", "tyuhiksd"] do
      assert strong_password?(id) ==
      "The password should contain at least one number and one punctuation character."
    end
  end

  test "password with no digit" do
    for id <- ["hf:jksh#fhj", "au$ykkjkjh", "(tyu)hiksd"] do
      assert strong_password?(id) ==
      "The password should contain at least one number and one punctuation character."
    end
  end

  test "password with no symbol" do
    for id <- ["h8fjkshfhj", "auykk2jkj1h", "0tyuhi67ksd"] do
      assert strong_password?(id) ==
      "The password should contain at least one number and one punctuation character."
    end
  end

end
