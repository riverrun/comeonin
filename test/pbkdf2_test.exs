defmodule Comeonin.Pbkdf2Test do
  use ExUnit.Case

  alias Comeonin.Pbkdf2

  def check_vectors(data) do
    for {password, salt, rounds, stored_hash} <- data do
      assert Pbkdf2.hashpass(password, salt, rounds) == stored_hash
    end
  end

  test "basic pbkdf2_sha512 tests" do
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

  test "Python passlib pbkdf2_sha512 tests" do
    [
      {"password",
        <<36, 196, 248, 159, 51, 166, 84, 170, 213, 250, 159, 211, 154, 83, 10, 193>>,
        19000,
        "$pbkdf2-sha512$19000$JMT4nzOmVKrV.p/TmlMKwQ$jKbZHoPwUWBT08pjb/CnUZmFcB9JW4dsOzVkfi9X6Pdn5NXWeY.mhL1Bm4V9rjYL5ZfA32uh7Gl2gt5YQa/JCA"},
      {"p@$$w0rd",
        <<252, 159, 83, 202, 89, 107, 141, 17, 66, 200, 121, 239, 29, 163, 20, 34>>,
        19000,
        "$pbkdf2-sha512$19000$/J9TyllrjRFCyHnvHaMUIg$AJ3Dr926ltK1sOZMZAAoT7EoR7R/Hp.G6Bt.4DFENiYayhVM/ZBPuqjFNhcE9NjTmceTmLnSqzfEQ8mafy49sw"},
      {"oh this is hard 2 guess",
        <<1, 96, 140, 17, 162, 84, 42, 165, 84, 42, 165, 244, 62, 71, 136, 177>>,
        19000,
        "$pbkdf2-sha512$19000$AWCMEaJUKqVUKqX0PkeIsQ$F0xkzJUOKaH8pwAfEwLeZK2/li6CF3iEcpfoJ1XoExQUTStXCNVxE1sd1k0aeQlSFK6JnxJOjM18kZIdzNYkcQ"},
      {"even more difficult",
        <<215, 186, 87, 42, 133, 112, 14, 1, 160, 52, 38, 100, 44, 229, 92, 203>>,
        19000,
        "$pbkdf2-sha512$19000$17pXKoVwDgGgNCZkLOVcyw$TEv9woSaVTsYHLxXnFbWO1oKrUGfUAljkLnqj8W/80BGaFbhccG8B9fZc05RoUo7JQvfcwsNee19g8GD5UxwHA"}
    ]
  |> check_vectors
  end

  test "Consistency tests" do
   [{"funferal",
     <<192, 39, 248, 127, 11, 37, 71, 252, 74, 75, 244, 70, 129, 27, 51, 71>>,
     "$pbkdf2-sha512$60000$wCf4fwslR/xKS/RGgRszRw$QJHazw8zTaY0HvGQF1Slb07Ug9DFFLjoq63aORwhA.o/OM.e9UpxldolWyCNLv3duHuxpEWoZtGHfm3VTFCqpg"},
   {"he's N0t the Me551ah!",
     <<60, 130, 11, 97, 11, 23, 236, 250, 227, 233, 56, 1, 86, 131, 41, 163>>,
     "$pbkdf2-sha512$60000$PIILYQsX7Prj6TgBVoMpow$tsPUY4uMzTbJuv81xxZzsUGvT1LGjk9EfJuAYoZH9KaCSGH90J8BuQwY4Jb0JZbwOI00BSR4hDBVmn3Z8V.Ywg"}]
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

  test "wrong input to gen_salt" do
    assert_raise ArgumentError, "The salt is the wrong length.", fn ->
      Pbkdf2.gen_salt(15)
    end
    assert_raise ArgumentError, "The salt is the wrong length.", fn ->
      Pbkdf2.gen_salt(1025)
    end
  end
end
