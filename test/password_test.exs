defmodule Comeonin.PasswordTest do
  use ExUnit.Case, async: true

  alias Comeonin.Password

  test "password default length config" do
    assert Password.gen_password(8) |> String.length == 8
    assert Password.gen_password(16) |> String.length == 16
  end

  test "password minimum length config" do
    assert Password.strong_password?("4ghY&j2", [min_length: 6]) == true
    assert Password.strong_password?("4ghY&j2", [min_length: 8]) ==
    "The password should be at least 8 characters long."
  end

  test "password with a digit and a symbol" do
    for id <- ["hfjkshf6hj#", "8auyk kjkjh", "ty3uhi@ksd"] do
      assert Password.strong_password?(id) == true
    end
  end

  test "password with no digit or symbol" do
    for id <- ["hfjkshfhj", "auykkjkjh", "tyuhiksd"] do
      assert Password.strong_password?(id) ==
      "The password should contain at least one number and one punctuation character."
    end
  end

  test "password with no digit" do
    for id <- ["hf:jksh#fhj", "au$ykkjkjh", "(tyu)hiksd"] do
      assert Password.strong_password?(id) ==
      "The password should contain at least one number and one punctuation character."
    end
  end

  test "password with no symbol" do
    for id <- ["h8fjkshfhj", "auykk2jkj1h", "0tyuhi67ksd"] do
      assert Password.strong_password?(id) ==
      "The password should contain at least one number and one punctuation character."
    end
  end

  test "gen_password produces strong password" do
    assert Password.gen_password(8) |> Password.strong_password? == true
    assert Password.gen_password() |> Password.strong_password? == true
  end

end
