defmodule ComeoninTest do
  use ExUnit.Case, async: true

  test "bcrypt create_hash password validation" do
    assert Comeonin.create_hash("password") ==
    {:error, "The password should contain at least one number and one punctuation character."}

    {:ok, hash} = Comeonin.create_hash("pas$w0rd")
    assert String.starts_with?(hash, "$2b$")
  end

  test "create_hash with no password validation" do
    {:ok, hash} = Comeonin.create_hash("pass", false)
    assert String.starts_with?(hash, "$2b$")
  end

  test "pbkdf2 create_hash password validation" do
    Application.put_env(:comeonin, :crypto_mod, :pbkdf2)
    assert Comeonin.create_hash("password") ==
    {:error, "The password should contain at least one number and one punctuation character."}

    {:ok, hash} = Comeonin.create_hash("pas$w0rd")
    assert String.starts_with?(hash, "$pbkdf2-sha512$")
    Application.delete_env(:comeonin, :crypto_mod)
  end

  test "create user map key is string" do
    {:ok, params} = %{"name" => "fred", "password" => "&m@ng0es"}
              |> Comeonin.create_user
    assert Map.has_key?(params, "password_hash")
    refute Map.has_key?(params, "password")
  end

  test "create user map where map key is atom" do
    {:ok, params} = %{name: "fred", password: "&m@ng0es"}
              |> Comeonin.create_user
    assert Map.has_key?(params, :password_hash)
    refute Map.has_key?(params, :password)
  end

  test "create user map where map key is neither string nor atom" do
    assert Comeonin.create_user(%{ ["name"] => "fred", ["password", "password_admin"] => "&m@ng0es" }) ===
    {:error, "user_params has neither atom nor string as password key"}
  end

  test "create user map with no password validation" do
    {:ok, params} = %{"name" => "joe", "password" => "gooseberries"}
              |> Comeonin.create_user(false)
    assert Map.has_key?(params, "password_hash")
    refute Map.has_key?(params, "password")
  end

  test "create user map error" do
    assert %{"name" => "joe", "password" => "gooseberries"} |> Comeonin.create_user ==
    {:error, "The password should contain at least one number and one punctuation character."}
  end

end
