defmodule Comeonin.ToolsTest do
  use ExUnit.Case, async: true

  alias Comeonin.Tools

  test "password default length config" do
    assert Tools.gen_password(8) |> String.length == 8
    assert Tools.gen_password(16) |> String.length == 16
  end

end
