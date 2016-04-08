defmodule Comeonin.BcryptTest do
  use ExUnit.Case, async: false

  alias Comeonin.Bcrypt

  def check_vectors(data) do
    for {password, salt, stored_hash} <- data do
      assert Bcrypt.hashpass(password, salt) == stored_hash
    end
  end

  def hash_check_password(password, wrong1, wrong2, wrong3) do
    hash = Bcrypt.hashpwsalt(password)
    assert Bcrypt.checkpw(password, hash) == true
    assert Bcrypt.checkpw(wrong1, hash) == false
    assert Bcrypt.checkpw(wrong2, hash) == false
    assert Bcrypt.checkpw(wrong3, hash) == false
  end

  test "Openwall Bcrypt tests" do
    [{"U*U",
      "$2a$05$CCCCCCCCCCCCCCCCCCCCC.",
      "$2a$05$CCCCCCCCCCCCCCCCCCCCC.E5YPO9kmyuRGyh0XouQYb4YMJKvyOeW"},
     {"U*U*",
      "$2a$05$CCCCCCCCCCCCCCCCCCCCC.",
      "$2a$05$CCCCCCCCCCCCCCCCCCCCC.VGOzA784oUp/Z0DY336zx7pLYAy0lwK"},
     {"U*U*U",
      "$2a$05$XXXXXXXXXXXXXXXXXXXXXO",
      "$2a$05$XXXXXXXXXXXXXXXXXXXXXOAcXxm9kjPGEMsLznoKqmqw7tc8WCx4a"},
     {"",
      "$2a$05$CCCCCCCCCCCCCCCCCCCCC.",
      "$2a$05$CCCCCCCCCCCCCCCCCCCCC.7uG0VCzI2bS7j6ymqJi9CdcdxiRTWNy"},
     {"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
      "$2a$05$abcdefghijklmnopqrstuu",
      "$2a$05$abcdefghijklmnopqrstuu5s2v8.iXieOjg/.AySBTTZIIVFJeBui"}]
    |> check_vectors
  end

  test "OpenBSD Bcrypt tests" do
    [{<<0xa3>>,
      "$2b$05$/OK.fbVrR/bpIqNJ5ianF.",
      "$2b$05$/OK.fbVrR/bpIqNJ5ianF.Sa7shbm4.OzKpvFnX1pQLmQW96oUlCq"},
     {<<0xa3>>,
      "$2a$05$/OK.fbVrR/bpIqNJ5ianF.",
      "$2a$05$/OK.fbVrR/bpIqNJ5ianF.Sa7shbm4.OzKpvFnX1pQLmQW96oUlCq"},
     {<<0xff, 0xff, 0xa3>>,
      "$2b$05$/OK.fbVrR/bpIqNJ5ianF.",
      "$2b$05$/OK.fbVrR/bpIqNJ5ianF.CE5elHaaO4EbggVDjb8P19RukzXSM3e"},
     {"000000000000000000000000000000000000000000000000000000000000000000000000",
      "$2a$05$CCCCCCCCCCCCCCCCCCCCC.",
      "$2a$05$CCCCCCCCCCCCCCCCCCCCC.6.O1dLNbjod2uo0DVcW.jHucKbPDdHS"},
     {"000000000000000000000000000000000000000000000000000000000000000000000000",
      "$2b$05$CCCCCCCCCCCCCCCCCCCCC.",
      "$2b$05$CCCCCCCCCCCCCCCCCCCCC.6.O1dLNbjod2uo0DVcW.jHucKbPDdHS"}]
    |> check_vectors
  end

  test "Long password $2b$ prefix tests" do
    [{"01234567890123456789012345678901234567890123456789012345678901234567890123456789" <>
       "0123456789012345678901234567890123456789012345678901234567890123456789012345678" <>
       "901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234",
      "$2b$05$CCCCCCCCCCCCCCCCCCCCC.",
      "$2b$05$CCCCCCCCCCCCCCCCCCCCC.XxrQqgBi/5Sxuq9soXzDtjIZ7w5pMfK"},
     {"01234567890123456789012345678901234567890123456789012345678901234567890123456789" <>
       "0123456789012345678901234567890123456789012345678901234567890123456789012345678" <>
       "9012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345",
      "$2b$05$CCCCCCCCCCCCCCCCCCCCC.",
      "$2b$05$CCCCCCCCCCCCCCCCCCCCC.XxrQqgBi/5Sxuq9soXzDtjIZ7w5pMfK"}]
    |> check_vectors
  end

  test "Long password old $2a$ prefix tests" do
    [{"01234567890123456789012345678901234567890123456789012345678901234567890123456789" <>
       "0123456789012345678901234567890123456789012345678901234567890123456789012345678" <>
       "901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234",
      "$2a$05$CCCCCCCCCCCCCCCCCCCCC.",
      "$2a$05$CCCCCCCCCCCCCCCCCCCCC.6.O1dLNbjod2uo0DVcW.jHucKbPDdHS"},
     {"01234567890123456789012345678901234567890123456789012345678901234567890123456789" <>
       "0123456789012345678901234567890123456789012345678901234567890123456789012345678" <>
       "9012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345",
      "$2a$05$CCCCCCCCCCCCCCCCCCCCC.",
      "$2a$05$CCCCCCCCCCCCCCCCCCCCC.6.O1dLNbjod2uo0DVcW.jHucKbPDdHS"}]
    |> check_vectors
  end

  test "raise error if salt has unsupported prefix" do
    assert_raise ArgumentError, "Comeonin Bcrypt does not support the 2x prefix.", fn ->
      Bcrypt.hashpass("U*U", "$2x$05$CCCCCCCCCCCCCCCCCCCCC.")
    end
    assert_raise ArgumentError, "Comeonin Bcrypt does not support the 2y prefix.", fn ->
      Bcrypt.hashpass("U*U", "$2y$05$CCCCCCCCCCCCCCCCCCCCC.")
    end
  end

  test "known non-ascii characters tests" do
    [{"ππππππππ",
      "$2a$10$.TtQJ4Jr6isd4Hp.mVfZeu",
      "$2a$10$.TtQJ4Jr6isd4Hp.mVfZeuh6Gws4rOQ/vdBczhDx.19NFK0Y84Dle"}]
    |> check_vectors
  end

  test "Consistency tests" do
    [{"p@5sw0rd",
      "$2b$12$zQ4CooEXdGqcwi0PHsgc8e",
      "$2b$12$zQ4CooEXdGqcwi0PHsgc8eAf0DLXE/XHoBE8kCSGQ97rXwuClaPam"},
     {"C'est bon, la vie!",
      "$2b$12$cbo7LZ.wxgW4yxAA5Vqlv.",
      "$2b$12$cbo7LZ.wxgW4yxAA5Vqlv.KR6QFPt4qCdc9RYJNXxa/rbUOp.1sw."},
     {"ἓν οἶδα ὅτι οὐδὲν οἶδα",
      "$2b$12$LeHKWR2bmrazi/6P22Jpau",
      "$2b$12$LeHKWR2bmrazi/6P22JpauX5my/eKwwKpWqL7L5iEByBnxNc76FRW"}]
    |> check_vectors
  end

  test "Bcrypt dummy check" do
    assert Bcrypt.dummy_checkpw == false
  end

  test "hashing and checking passwords" do
    hash_check_password("password", "passwor", "passwords", "pasword")
    hash_check_password("hard2guess", "ha rd2guess", "had2guess", "hardtoguess")
  end

  test "hashing and checking passwords with characters from the extended ascii set" do
    hash_check_password("aáåäeéêëoôö", "aáåäeéêëoö", "aáåeéêëoôö", "aáå äeéêëoôö")
    hash_check_password("aáåä eéêëoôö", "aáåä eéê ëoö", "a áåeé êëoôö", "aáå äeéêëoôö")
  end

  test "hashing and checking passwords with non-ascii characters" do
    hash_check_password("Сколько лет, сколько зим", "Сколько лет,сколько зим",
                        "Сколько лет сколько зим", "Сколько лет, сколько")
    hash_check_password("สวัสดีครับ", "สวัดีครับ", "สวัสสดีครับ", "วัสดีครับ")
  end

  test "hashing and checking passwords with mixed characters" do
    hash_check_password("Я❤três☕ où☔", "Я❤tres☕ où☔", "Я❤três☕où☔", "Я❤três où☔")
  end

  test "gen_salt number of rounds" do
    assert String.starts_with?(Bcrypt.gen_salt(8), "$2b$08$")
    assert String.starts_with?(Bcrypt.gen_salt(20), "$2b$20$")
  end

  test "gen_salt length of salt" do
    assert byte_size(Bcrypt.gen_salt) == 29
    assert byte_size(Bcrypt.gen_salt(8)) == 29
    assert byte_size(Bcrypt.gen_salt(20)) == 29
  end

  test "wrong input to gen_salt" do
    assert String.starts_with?(Bcrypt.gen_salt(3), "$2b$04$")
    assert String.starts_with?(Bcrypt.gen_salt(32), "$2b$31$")
    assert_raise ArgumentError, "Wrong type. log_rounds should be an integer between 4 and 31.", fn ->
      Bcrypt.gen_salt(["wrong type"])
    end
  end

  test "gen_salt with support for $2a$ prefix" do
    assert String.starts_with?(Bcrypt.gen_salt(8, true), "$2a$08$")
    assert String.starts_with?(Bcrypt.gen_salt(12, true), "$2a$12$")
  end

  test "trying to run hashpass without a salt" do
    assert_raise ArgumentError, "The salt is the wrong length.", fn ->
      Bcrypt.hashpass("U*U", "")
    end
  end

  test "wrong input to hashpass" do
    assert_raise ArgumentError, "The salt is the wrong length.", fn ->
      Bcrypt.hashpass("U*U", "$2a$05$CCCCCCCCCCCCCCCCCCC.")
    end
    assert_raise ArgumentError, "Wrong type. The password and salt need to be strings.", fn ->
      Bcrypt.hashpass(["U*U"], "$2a$05$CCCCCCCCCCCCCCCCCCCCC.")
    end
  end

  test "length of state output by NIFs" do
    salt_as_list = Bcrypt.gen_salt |> :erlang.binary_to_list
    for {key, key_len} <- [{'', 1}, {'password', 9}] do
      state = Bcrypt.bf_init(key, key_len, salt_as_list)
      assert byte_size(state) == 4168
      expanded = Bcrypt.bf_expand(state, key, key_len, salt_as_list)
      assert byte_size(expanded) == 4168
    end
  end

  test "bcrypt_log_rounds configuration" do
    prefix = "$2b$08$"
    Application.put_env(:comeonin, :bcrypt_log_rounds, 8)
    assert String.starts_with?(Bcrypt.gen_salt, prefix)
    assert String.starts_with?(Bcrypt.hashpwsalt("password"), prefix)
    Application.delete_env(:comeonin, :bcrypt_log_rounds)
  end

  test "wrong input to checkpw" do
    assert_raise ArgumentError, "Wrong type. The password and hash need to be strings.", fn ->
      Bcrypt.checkpw("U*U", '$2a$05$CCCCCCCCCCCCCCCCCCCCC.E5YPO9kmyuRGyh0XouQYb4YMJKvyOeW')
    end
    assert_raise ArgumentError, "Wrong type. The password and hash need to be strings.", fn ->
      Bcrypt.checkpw(nil, "$2a$05$CCCCCCCCCCCCCCCCCCCCC.E5YPO9kmyuRGyh0XouQYb4YMJKvyOeW")
    end
  end
end
