ExUnit.start()

defmodule ComeoninTestHelper do
  use ExUnit.Case

  @algs [Comeonin.Argon2, Comeonin.Bcrypt, Comeonin.Pbkdf2]

  def check_pass_check(password, wrong_list) do
    for crypto <- @algs do
      hash = crypto.hashpwsalt(password)
      user = %{id: 2, name: "fred", password_hash: hash}
      assert crypto.check_pass(user, password) == {:ok, user}
      assert crypto.check_pass(nil, password) == {:error, "invalid user-identifier"}

      for wrong <- wrong_list do
        assert crypto.check_pass(user, wrong) == {:error, "invalid password"}
      end
    end
  end

  def add_hash_check(password, wrong_list) do
    for crypto <- @algs do
      %{password_hash: hash, password: nil} = crypto.add_hash(password)
      assert crypto.checkpw(password, hash)

      for wrong <- wrong_list do
        refute crypto.checkpw(wrong, hash)
      end
    end
  end

  def hash_check(password, wrong_list) do
    for crypto <- @algs do
      hash = crypto.hashpwsalt(password)
      assert crypto.checkpw(password, hash)

      for wrong <- wrong_list do
        refute crypto.checkpw(wrong, hash)
      end
    end
  end
end
