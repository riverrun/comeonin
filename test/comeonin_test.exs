defmodule ComeoninTest do
  use ExUnit.Case

  import ExUnit.CaptureIO
  import ComeoninTestHelper

  @algs [Comeonin.Argon2, Comeonin.Bcrypt, Comeonin.Pbkdf2]

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
    for crypto <- @algs do
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
    for crypto <- @algs do
      assert {:ok, user} = crypto.add_hash("password") |> crypto.check_pass("password")
      assert {:error, "invalid password"} = crypto.add_hash("pass") |> crypto.check_pass("password")
      assert Map.has_key?(user, :password_hash)
    end
  end

  test "add_hash with a custom hash_key and check_pass" do
    for crypto <- @algs do
      assert {:ok, user} = crypto.add_hash("password", hash_key: :encrypted_password)
                           |> crypto.check_pass("password")
      assert {:error, "invalid password"} = crypto.add_hash("pass", hash_key: :encrypted_password)
                                            |> crypto.check_pass("password")
      assert Map.has_key?(user, :encrypted_password)
    end
  end

  test "check_pass with invalid hash_key" do
    for crypto <- @algs do
      {:error, message} = crypto.add_hash("password", hash_key: :unconventional_name)
                          |> crypto.check_pass("password")
      assert message =~ "no password hash found"
    end
  end

  test "check_pass with password that is not a string" do
    for crypto <- @algs do
      assert {:error, message} = crypto.add_hash("pass") |> crypto.check_pass(nil)
      assert message =~ "password is not a string"
    end
  end

  test "print stats report" do
    for crypto <- @algs do
      report = capture_io(fn -> crypto.report() end)
      assert report =~ "Verification OK"
    end
  end

  test "print stats report with options" do
    report = capture_io(fn -> Comeonin.Pbkdf2.report([digest: :sha256]) end)
    assert report =~ "Digest:\t\tpbkdf2-sha256\n"
    assert report =~ "Digest length:\t32\n"
    assert report =~ "Verification OK"
    report = capture_io(fn -> Comeonin.Argon2.report([t_cost: 8, m_cost: 18]) end)
    assert report =~ "Iterations:\t8\n"
    assert report =~ "Memory:\t\t256 MiB\n"
    assert report =~ "Verification OK"
    report = capture_io(fn -> Comeonin.Bcrypt.report(log_rounds: 10) end)
    assert report =~ "Hash:\t\t$2b$10$"
    assert report =~ "Verification OK"
  end

end
