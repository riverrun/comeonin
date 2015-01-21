defmodule Comeonin.Pbkdf2Test do
  use ExUnit.Case

  alias Comeonin.Pbkdf2

  def check_vectors(data) do
    for {password, salt, rounds, stored_hash} <- data do
      assert Pbkdf2.hashpass(password, salt, rounds) == stored_hash
    end
  end

  test "pbkdf2_sha512 tests" do
    [
      {"",
        <<115, 97, 108, 116>>,
        1024,
        "$pbkdf2-sha512$1024$c2FsdA$xHRxDO333TEJTVDgqjz9xltmBrTyrJLUyrnY7tfcrqe2ewobAK8fOHr6oD9Tqz0zU4cXrH5E.QQfctLUyu6N7A"},
      {"password",
        <<>>,
        1024,
        "$pbkdf2-sha512$1024$$GABWyrGTs3ovDBwRO8V68EZO.L4dCVi2e19wRI/s4q2seodgNoBFpxpC4wSr066E4IjWG0uLLlDF4r5bTUGeow"},
      {"password",
        <<115, 97, 108, 116>>,
        4096,
        "$pbkdf2-sha512$4096$c2FsdA$0Zexsz2wFD4BixLz0dFHnmzevcyXxcD4f2kC4HL0V7UUPzBgJkGz1VzTNZiMs2uEN2Bg7NUy4Dm3QqI5Q0ry1Q"}
    ]
  |> check_vectors
  end

  test "pbkdf2 dummy check" do
    assert Pbkdf2.dummy_checkpw == false
  end

  test "hashing and checking passwords" do
    hash = Pbkdf2.hashpwsalt("password")
    assert Pbkdf2.checkpw("password", hash) == true
    assert Pbkdf2.checkpw("passwor", hash) == false
    assert Pbkdf2.checkpw("passwords", hash) == false
    assert Pbkdf2.checkpw("pasword", hash) == false
  end
end
