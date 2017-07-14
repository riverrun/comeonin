defmodule ComeoninTest do
  use ExUnit.Case, async: true

  import ComeoninTestHelper

  test "hashing and checking passwords" do
    wrong_list = ["aged2h$ru", "2dau$ehgr", "rg$deh2au", "2edrah$gu", "$agedhur2", ""]
    hash_check("hard2guess", wrong_list)
  end

  test "hashing and checking passwords with characters from the extended ascii set" do
    wrong_list = ["eáé åöêô ëaäo", "aäôáö eéoêë å", " aöêôée oåäëá", "åaêöéäëeoô á ", ""]
    hash_check("aáåä eéê ëoôö", wrong_list)
  end

  test "hashing and checking passwords with non-ascii characters" do
    wrong_list = ["и Скл;лекьоток к олсомзь", "кеокок  зС омлслтььлок;и", "е  о оиькльлтСо;осккклзм", ""]
    hash_check("Сколько лет; сколько зим", wrong_list)
  end

  test "hashing and checking passwords with mixed characters" do
    wrong_list = ["Я☕t☔s❤ùo", "o❤ Я☔ùrtês☕", " ùt❤o☕☔srêЯ", "ù☕os êt❤☔rЯ", ""]
    hash_check("Я❤três☕ où☔", wrong_list)
  end

  test "check password using check_pass, which uses the user map as input" do
    wrong_list = ["บดสคสััีวร", "สดรบัีสัคว", "สวดัรคบัสี", "ดรสสีวคบัั", "วรคดสัสีับ", ""]
    check_pass_check("สวัสดีครับ", wrong_list)
  end

  test "add hash to map and set password to nil" do
    wrong_list = ["êäöéaoeôáåë", "åáoêëäéôeaö", "aäáeåëéöêôo", ""]
    add_hash_check("aáåäeéêëoôö", wrong_list)
  end

  test "user obfuscation function always returns false" do
    for crypto <- [Comeonin.Argon2, Comeonin.Bcrypt, Comeonin.Pbkdf2] do
      assert crypto.dummy_checkpw() == false
    end
  end

  test "opts are passed on to the underlying function" do
    hash = Comeonin.Argon2.hashpwsalt("", t_cost: 2, m_cost: 12)
    assert String.starts_with?(hash, "$argon2i$v=19$m=4096,t=2")
    hash = Comeonin.Bcrypt.hashpwsalt("", log_rounds: 10)
    assert String.starts_with?(hash, "$2b$10$")
    hash = Comeonin.Pbkdf2.hashpwsalt("", rounds: 200, digest: :sha256)
    assert String.starts_with?(hash, "$pbkdf2-sha256$200$")
  end

  test "add_hash and check_pass" do
    for crypto <- [Comeonin.Argon2, Comeonin.Bcrypt, Comeonin.Pbkdf2] do
      assert {:ok, _} = crypto.add_hash("password") |> crypto.check_pass("password")
      assert {:error, "invalid password"} = crypto.add_hash("pass") |> crypto.check_pass("password")
    end
  end

  test "add_encoded and check_pass" do
    for crypto <- [Comeonin.Argon2, Comeonin.Bcrypt, Comeonin.Pbkdf2] do
      assert {:ok, _} = crypto.add_encoded("password") |> crypto.check_pass("password")
      assert {:error, "invalid password"} = crypto.add_encoded("pass") |> crypto.check_pass("password")
    end
  end

end
