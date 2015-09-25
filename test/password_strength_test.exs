defmodule Comeonin.PasswordStrengthTest do
  use ExUnit.Case, async: true

  import Comeonin.PasswordStrength

  test "password minimum length config" do
    assert strong_password?("4ghY&j2", [min_length: 6]) == true
    assert strong_password?("4ghY&j2", [min_length: 8]) ==
    "The password should be at least 8 characters long."
  end

  test "passwords with a digit and a symbol" do
    for id <- ["hfjkshf6hj#", "8auyk kjkjh", "ty3uhi@ksd"] do
      assert strong_password?(id) == true
    end
  end

  test "passwords with no digit or symbol" do
    for id <- ["hfjkshfhj", "auykkjkjh", "tyuhiksd"] do
      assert strong_password?(id) ==
      "The password should contain at least one number and one punctuation character."
    end
  end

  test "passwords with no digit" do
    for id <- ["hf:jksh#fhj", "au$ykkjkjh", "(tyu)hiksd"] do
      assert strong_password?(id) ==
      "The password should contain at least one number and one punctuation character."
    end
  end

  test "passwords with no symbol" do
    for id <- ["h8fjkshfhj", "auykk2jkj1h", "0tyuhi67ksd"] do
      assert strong_password?(id) ==
      "The password should contain at least one number and one punctuation character."
    end
  end

  test "common passwords" do
    for id <- ["password", "qwertyuiop", "excalibur"] do
      assert strong_password?(id, [min_length: 8, extra_chars: false]) ==
      "The password you have chosen is weak because it is easy to guess. Please choose another one."
    end
  end

  test "common passwords with uppercase letters" do
    for id <- ["aSSaSsin", "DolPHIns", "sTaRwArS"] do
      assert strong_password?(id, [min_length: 8, extra_chars: false]) ==
      "The password you have chosen is weak because it is easy to guess. Please choose another one."
    end
  end

  test "common passwords with substitutions" do
    for id <- ["5(o0byd0o", "qw3r+y12e", "@lp#4!ze"] do
      assert strong_password?(id) ==
      "The password you have chosen is weak because it is easy to guess. Please choose another one."
    end
  end

  test "common passwords with substitutions and an appended letter" do
    for id <- ["d09#ov$31", "p4vem3n+1", "*m4rip0s@"] do
      assert strong_password?(id) ==
      "The password you have chosen is weak because it is easy to guess. Please choose another one."
    end
  end

  test "uncommon passwords" do
    for id <- ["8(o0b$d0o", "Gw3r+y12e", "@lT#4z!e"] do
      assert strong_password?(id) == true
    end
  end

end
