defmodule ComeoninTest do
  use ExUnit.Case, async: true

  def hash_check_password(password, wrong) do
    for crypto <- [Argon2, Bcrypt, Pbkdf2] do
      %{password_hash: hash} = Comeonin.add_hash(%{password: password}, crypto)
      user = %{id: 2, name: "fred", password_hash: hash}
      assert Comeonin.check_pass(user, password, crypto) == {:ok, user}
      assert Comeonin.check_pass(nil, password, crypto) == {:error, "invalid user-identifier"}
      assert Comeonin.check_pass(user, wrong, crypto) == {:error, "invalid password"}
    end
  end

  def add_hash_map(password, wrong) do
    changes = %{password: password}
    for crypto <- [Argon2, Bcrypt, Pbkdf2] do
      %{password_hash: hash, password: nil} = Comeonin.add_hash(changes, crypto)
      assert crypto.verify_pass(password, hash) == true
      assert crypto.verify_pass(wrong, hash) == false
    end
  end

  test "hashing and checking passwords" do
    hash_check_password("password", "passwor")
    hash_check_password("hard2guess", "ha rd2guess")
  end

  test "hashing and checking passwords with characters from the extended ascii set" do
    hash_check_password("aáåäeéêëoôö", "aáåäeéêëoö")
    hash_check_password("aáåä eéêëoôö", "aáåä eéê ëoö")
  end

  test "hashing and checking passwords with non-ascii characters" do
    hash_check_password("Сколько лет, сколько зим", "Сколько лет,сколько зим")
    hash_check_password("สวัสดีครับ", "สวัดีครับ")
  end

  test "hashing and checking passwords with mixed characters" do
    hash_check_password("Я❤três☕ où☔", "Я❤tres☕ où☔")
  end

  test "add hash to map and set password to nil" do
    add_hash_map("password", "pass word")
    add_hash_map("Сколько лет, сколько зим", "Сколько лет,сколько зим")
  end

end
