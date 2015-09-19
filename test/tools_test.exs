defmodule Comeonin.ToolsTest do
  use ExUnit.Case, async: true

  alias Comeonin.Tools

  test "length of random_bytes" do
    for num <- [16, 4, 12, 24, 32] do
      assert Tools.random_bytes(num) |> byte_size == num
    end
  end

  test "wrong input to random_bytes" do
    assert_raise ArgumentError, "Wrong type. You must call this function with an integer.", fn ->
      Tools.random_bytes("16")
    end
    assert_raise ArgumentError, "Wrong type. You must call this function with an integer.", fn ->
      Tools.random_bytes(16.55)
    end
  end

  test "password default length config" do
    assert Tools.gen_password(8) |> String.length == 8
    assert Tools.gen_password(16) |> String.length == 16
  end

end
