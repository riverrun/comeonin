defmodule Comeonin.ToolsTest do
  use ExUnit.Case, async: true

  alias Comeonin.Tools
  import Comeonin.PasswordStrength

  test "random password length" do
    assert Tools.random_key(8) |> String.length == 8
    assert Tools.random_key(16) |> String.length == 16
    assert Tools.random_key |> String.length == 12
  end

  test "random password too short length" do
    for len <- 1..7 do
      assert_raise ArgumentError, "The password should be at least 8 characters long.", fn ->
        Tools.random_key(len)
      end
    end
  end

  test "stong password generated" do
    assert Tools.random_key |> strong_password? == true
  end

end
