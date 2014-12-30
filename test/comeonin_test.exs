defmodule ComeoninTest do
  use ExUnit.Case

  alias Comeonin.Bcrypt

  def check_vectors(data) do
    for {password, salt, stored_hash} <- data do
      assert Bcrypt.hashpass(password, salt) == stored_hash
    end
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
   [{"\xa3",
     "$2b$05$/OK.fbVrR/bpIqNJ5ianF.",
     "$2b$05$/OK.fbVrR/bpIqNJ5ianF.Sa7shbm4.OzKpvFnX1pQLmQW96oUlCq"},
    {"\xa3",
     "$2a$05$/OK.fbVrR/bpIqNJ5ianF.",
     "$2a$05$/OK.fbVrR/bpIqNJ5ianF.Sa7shbm4.OzKpvFnX1pQLmQW96oUlCq"},
    {"\xff\xff\xa3",
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

  test "Long password Bcrypt tests" do
   [{"012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234",
     "$2b$05$CCCCCCCCCCCCCCCCCCCCC.",
     "$2b$05$CCCCCCCCCCCCCCCCCCCCC.XxrQqgBi/5Sxuq9soXzDtjIZ7w5pMfK"},
   {"0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345",
     "$2b$05$CCCCCCCCCCCCCCCCCCCCC.",
     "$2b$05$CCCCCCCCCCCCCCCCCCCCC.XxrQqgBi/5Sxuq9soXzDtjIZ7w5pMfK"}]
    |> check_vectors
  end

  test "Bcrypt dummy check" do
    assert Bcrypt.checkpw == false
  end

  test "hashing and checking passwords" do
    hash = Comeonin.hashpwsalt("password")
    assert Comeonin.checkpw("password", hash) == true
    assert Comeonin.checkpw("passwor", hash) == false
    assert Comeonin.checkpw("passwords", hash) == false
    assert Comeonin.checkpw("pasword", hash) == false
  end

  test "gen_salt number of rounds" do
    assert :lists.prefix('$2b$08$', Bcrypt.gen_salt(8)) == true
    assert :lists.prefix('$2b$20$', Bcrypt.gen_salt(20)) == true
  end

  test "gen_salt length of salt" do
    assert length(Bcrypt.gen_salt) == 29
    assert length(Bcrypt.gen_salt(8)) == 29
    assert length(Bcrypt.gen_salt(20)) == 29
    assert length(Bcrypt.gen_salt("wrong input but still works")) == 29
  end

  test "wrong input to gen_salt" do
    assert :lists.prefix('$2b$04$', Bcrypt.gen_salt(3)) == true
    assert :lists.prefix('$2b$31$', Bcrypt.gen_salt(32)) == true
    assert :lists.prefix('$2b$12$', Bcrypt.gen_salt(["wrong type"])) == true
  end

  test "wrong input to hashpass" do
    assert_raise ArgumentError, "The salt is the wrong length.", fn ->
      Bcrypt.hashpass("U*U", "$2a$05$CCCCCCCCCCCCCCCCCCC.")
    end
    assert_raise ArgumentError, "Wrong type. The password needs to be a string.", fn ->
      Bcrypt.hashpass(["U*U"], "$2a$05$CCCCCCCCCCCCCCCCCCCCC.")
    end
  end
end
