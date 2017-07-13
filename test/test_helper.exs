ExUnit.start()

defmodule ComeoninTestHelper do
  use ExUnit.Case

  def check_pass_check(password, wrong_list) do
    for crypto <- [Argon2, Bcrypt, Pbkdf2] do
      hash = crypto.hash_pwd_salt(password)
      user = %{id: 2, name: "fred", password_hash: hash}
      assert Comeonin.check_pass(user, password, crypto) == {:ok, user}
      assert Comeonin.check_pass(nil, password, crypto) == {:error, "invalid user-identifier"}
      for wrong <- wrong_list do
        assert Comeonin.check_pass(user, wrong, crypto) == {:error, "invalid password"}
      end
    end
  end

  def add_hash_check(password, wrong_list) do
    changes = %{password: password}
    for crypto <- [Argon2, Bcrypt, Pbkdf2] do
      %{password_hash: hash, password: nil} = Comeonin.add_hash(changes, crypto)
      assert crypto.verify_pass(password, hash)
      for wrong <- wrong_list do
        refute crypto.verify_pass(wrong, hash)
      end
    end
  end

  def hash_check(password, wrong_list) do
    for crypto <- [Comeonin.Argon2, Comeonin.Bcrypt, Comeonin.Pbkdf2] do
      hash = crypto.hashpwsalt(password)
      assert crypto.checkpw(password, hash)
      for wrong <- wrong_list do
        refute crypto.checkpw(wrong, hash)
      end
    end
  end
end
