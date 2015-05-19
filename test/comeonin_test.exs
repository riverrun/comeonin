defmodule ComeoninTest do
  use ExUnit.Case, async: true

  test "bcrypt signup_user password validation" do
    assert Comeonin.signup_user("password") ==
    {:error, "The password should contain at least one number and one punctuation character."}

    {:ok, hash} = Comeonin.signup_user("pas$w0rd")
    assert String.starts_with?(hash, "$2b$")
  end

  test "signup_user with no password validation" do
    {:ok, hash} = Comeonin.signup_user("pass", false)
    assert String.starts_with?(hash, "$2b$")
  end

  test "pbkdf2 signup_user password validation" do
    Application.put_env(:comeonin, :crypto_mod, :pbkdf2)
    assert Comeonin.signup_user("password") ==
    {:error, "The password should contain at least one number and one punctuation character."}

    {:ok, hash} = Comeonin.signup_user("pas$w0rd")
    assert String.starts_with?(hash, "$pbkdf2-sha512$")
    Application.delete_env(:comeonin, :crypto_mod)
  end

  test "create user map" do
    {:ok, params} = %{"name" => "fred", "password" => "&m@ng0es"}
              |> Comeonin.create_user
    assert Map.has_key?(params, "password_hash")
    refute Map.has_key?(params, "password")
  end

  test "create user map with no password validation" do
    {:ok, params} = %{"name" => "joe", "password" => "gooseberries"}
              |> Comeonin.create_user(false)
    assert Map.has_key?(params, "password_hash")
    refute Map.has_key?(params, "password")
  end

end
