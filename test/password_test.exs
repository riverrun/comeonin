defmodule Comeonin.PasswordTest do
  use ExUnit.Case, async: true

  alias Comeonin.Password

  test "valid password has a digit and a symbol" do
    for id <- ["hfjkshf6hj#", "8auyk>kjkjh", "ty3uhi@ksd"] do
      assert Password.valid_password?(id)
    end
  end

  test "invalid password has no digit or symbol" do
    for id <- ["hfjkshfhj", "auykkjkjh", "tyuhiksd"] do
      refute Password.valid_password?(id)
    end
  end

  test "invalid password has no digit" do
    for id <- ["hf:jksh#fhj", "au$ykkjkjh", "(tyu)hiksd"] do
      refute Password.valid_password?(id)
    end
  end

  test "invalid password has no symbol" do
    for id <- ["h8fjkshfhj", "auykk2jkj1h", "0tyuhi67ksd"] do
      refute Password.valid_password?(id)
    end
  end

  test "generate valid password" do
    assert Password.gen_password |> to_string |> Password.valid_password?
  end

end
