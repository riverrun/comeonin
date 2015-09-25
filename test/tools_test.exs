defmodule Comeonin.ToolsTest do
  use ExUnit.Case, async: true

  alias Comeonin.Tools
  import Comeonin.PasswordStrength

  test "password default length config" do
    assert Tools.gen_password(8) |> String.length == 8
    assert Tools.gen_password(16) |> String.length == 16
    assert Tools.gen_password |> String.length == 12
  end

  test "stong password generated" do
    assert Tools.gen_password |> strong_password? == true
  end

end
