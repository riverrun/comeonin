defmodule Comeonin.Pbkdf2Test do
  use ExUnit.Case, async: false

  alias Comeonin.Pbkdf2

  def check_vectors(data) do
    for {password, salt, rounds, stored_hash} <- data do
      assert Pbkdf2.hashpass(password, salt, rounds) == stored_hash
    end
  end
 
  test "base pbkdf2_sha512 tests" do
    [
      {"passDATAb00AB7YxDTT",
        "saltKEYbcTcXHCBxtjD",
        100_000,
        "$pbkdf2-sha512$100000$c2FsdEtFWWJjVGNYSENCeHRqRA$rM3Nh5iuXNhYBHOQFe8qEeMlkbe30W92gZswsNSdgOGr6myYIrgKH9/kIeJvVgPsqKR6ZMmgBPta.CKfdi/0Hw"},
      {"passDATAb00AB7YxDTTl",
        "saltKEYbcTcXHCBxtjD2",
        100_000,
        "$pbkdf2-sha512$100000$c2FsdEtFWWJjVGNYSENCeHRqRDI$WUJWsL1NbJ8hqH97pXcqeRoQ5hEGlPRDZc2UZw5X8a7NeX7x0QAZOHGQRMfwGAJml4Reua2X2X3jarh4aqtQlg"},
      {"passDATAb00AB7YxDTTlRH2dqxDx19GDxDV1zFMz7E6QVqKIzwOtMnlxQLttpE5",
        "saltKEYbcTcXHCBxtjD2PnBh44AIQ6XUOCESOhXpEp3HrcGMwbjzQKMSaf63IJe",
        100_000,
        "$pbkdf2-sha512$100000$c2FsdEtFWWJjVGNYSENCeHRqRDJQbkJoNDRBSVE2WFVPQ0VTT2hYcEVwM0hyY0dNd2JqelFLTVNhZjYzSUpl$B0R0AchXZuSu1YPeLmv1pnXqvk82GCgclWFvT8H9/m7LwcOYJ4nU/ZQdZYTvU0p4vTeuAlVdlFXo8In9tN.2uw"}
    ]
  |> check_vectors
  end

  test "Python passlib pbkdf2_sha512 tests" do
    [
      {"password",
        <<36, 196, 248, 159, 51, 166, 84, 170, 213, 250, 159, 211, 154, 83, 10, 193>>,
        19_000,
        "$pbkdf2-sha512$19000$JMT4nzOmVKrV.p/TmlMKwQ$jKbZHoPwUWBT08pjb/CnUZmFcB9JW4dsOzVkfi9X6Pdn5NXWeY.mhL1Bm4V9rjYL5ZfA32uh7Gl2gt5YQa/JCA"},
      {"p@$$w0rd",
        <<252, 159, 83, 202, 89, 107, 141, 17, 66, 200, 121, 239, 29, 163, 20, 34>>,
        19_000,
        "$pbkdf2-sha512$19000$/J9TyllrjRFCyHnvHaMUIg$AJ3Dr926ltK1sOZMZAAoT7EoR7R/Hp.G6Bt.4DFENiYayhVM/ZBPuqjFNhcE9NjTmceTmLnSqzfEQ8mafy49sw"},
      {"oh this is hard 2 guess",
        <<1, 96, 140, 17, 162, 84, 42, 165, 84, 42, 165, 244, 62, 71, 136, 177>>,
        19_000,
        "$pbkdf2-sha512$19000$AWCMEaJUKqVUKqX0PkeIsQ$F0xkzJUOKaH8pwAfEwLeZK2/li6CF3iEcpfoJ1XoExQUTStXCNVxE1sd1k0aeQlSFK6JnxJOjM18kZIdzNYkcQ"},
      {"even more difficult",
        <<215, 186, 87, 42, 133, 112, 14, 1, 160, 52, 38, 100, 44, 229, 92, 203>>,
        19_000,
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

  test "hashing and checking passwords with characters from the extended ascii set" do
    hash = Pbkdf2.hashpwsalt("aáåäeéêëoôö")
    assert Pbkdf2.checkpw("aáåäeéêëoôö", hash) == true
    assert Pbkdf2.checkpw("áåäeéêëoôö", hash) == false
    assert Pbkdf2.checkpw("aáåäeéêoôö", hash) == false
  end

  test "hashing and checking passwords with spaces" do
    hash = Pbkdf2.hashpwsalt("i am here")
    assert Pbkdf2.checkpw("i am here", hash) == true
    assert Pbkdf2.checkpw("i am  here", hash) == false
    assert Pbkdf2.checkpw("iam here", hash) == false
  end

  test "hashing and checking passwords with non-ascii characters" do
    hash = Pbkdf2.hashpwsalt("Сколько лет, сколько зим")
    assert Pbkdf2.checkpw("Сколько лет, сколько зим", hash) == true
    assert Pbkdf2.checkpw("Сколько, сколько зим", hash) == false
    assert Pbkdf2.checkpw("Сколько лет сколько зим", hash) == false
    hash = Pbkdf2.hashpwsalt("❤♨♈♀♁♂☸☯☔☕")
    assert Pbkdf2.checkpw("❤♨♈♀♁♂☸☯☔☕", hash) == true
    assert Pbkdf2.checkpw("❤♨♀♁♂☸☯☔☕", hash) == false
    assert Pbkdf2.checkpw("❤♨♈♀♁♂☹☯☕", hash) == false
  end

  test "gen_salt length of salt" do
    assert byte_size(Pbkdf2.gen_salt) == 16
    assert byte_size(Pbkdf2.gen_salt(32)) == 32
    assert byte_size(Pbkdf2.gen_salt(64)) == 64
  end

  test "wrong input to gen_salt" do
    assert_raise ArgumentError, "The salt is the wrong length.", fn ->
      Pbkdf2.gen_salt(15)
    end
    assert_raise ArgumentError, "The salt is the wrong length.", fn ->
      Pbkdf2.gen_salt(1025)
    end
  end

  test "trying to run hashpass without a salt" do
    assert_raise ArgumentError, "The salt is the wrong length.", fn ->
      Pbkdf2.hashpass("password", "")
    end
  end

  test "wrong input to hashpass" do
    assert_raise ArgumentError, "Wrong type. The salt needs to be a string.", fn ->
      Pbkdf2.hashpass("password", 'dontusecharlists')
    end
  end

  test "pbkdf2_rounds configuration" do
    prefix = "$pbkdf2-sha512$12000$"
    Application.put_env(:comeonin, :pbkdf2_rounds, 12_000)
    assert String.starts_with?(Pbkdf2.hashpass("password", Pbkdf2.gen_salt), prefix)
    assert String.starts_with?(Pbkdf2.hashpwsalt("password"), prefix)
    Application.delete_env(:comeonin, :pbkdf2_rounds)
  end
end
