defmodule Comeonin.BehaviourTest do
  @moduledoc """
  Test helper functions for Comeonin behaviours.
  """

  import ExUnit.Assertions

  # add data helpers - different character sets
  # add Comeonin behaviour helpers
  # add Comeonin.PasswordHash behaviour helpers

  @doc """
  Checks the hash_pwd_salt and verify_pass implementations.
  """
  def password_hash_check(module, password) do
    hash = module.hash_pwd_salt(password)
    assert module.verify_pass(password, hash)

    for wrong <- wrong_passwords(password) do
      assert module.verify_pass(wrong, hash) == false
    end
  end

  @doc """
  Checks the add_hash implementation.
  """
  def add_hash_check(module, password) do
    %{password_hash: hash, password: nil} = module.add_hash(password)
    assert module.verify_pass(password, hash)

    for wrong <- wrong_passwords(password) do
      assert module.verify_pass(wrong, hash) == false
    end
  end

  @doc """
  Checks the check_pass implementation.
  """
  def check_pass_check(module, password) do
    hash = module.hash_pwd_salt(password)
    user = %{id: 2, name: "fred", password_hash: hash}
    assert module.check_pass(user, password) == {:ok, user}
    assert module.check_pass(nil, password) == {:error, "invalid user-identifier"}

    for wrong <- wrong_passwords(password) do
      assert module.check_pass(user, wrong) == {:error, "invalid password"}
    end
  end

  defp wrong_passwords(password) do
    words = [password, String.duplicate(password, 2)]
    reversed = Enum.map(words, &String.reverse(&1))
    Enum.flat_map(words ++ reversed, &slices/1)
  end

  defp slices(password) do
    ranges = [{1, -1}, {0, -2}, {2, -1}, {2, -2}]
    for {first, last} <- ranges, do: String.slice(password, first..last)
  end
end
