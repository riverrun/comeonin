defmodule ComeoninTest do
  use ExUnit.Case, async: true

  test "bcrypt create_hash with default check" do
    assert Comeonin.create_hash("password") ==
    {:error, "The password should contain at least one number and one punctuation character."}

    assert Comeonin.create_hash("pa$w0rd") ==
    {:error, "The password should be at least 8 characters long."}

    {:ok, hash} = Comeonin.create_hash("pas$w0rd")
    assert String.starts_with?(hash, "$2b$")
  end

  test "create_hash with no check for punctuation characters or digits" do
    {:ok, hash} = Comeonin.create_hash("longboringpassword", [extra_chars: false])
    assert String.starts_with?(hash, "$2b$")
  end

  test "password too short when no check for punctuation characters or digits" do
    assert Comeonin.create_hash("password", [extra_chars: false]) ==
    {:error, "The password should be at least 12 characters long."}
  end

  test "pbkdf2 create_hash with default check" do
    Application.put_env(:comeonin, :crypto_mod, :pbkdf2)
    assert Comeonin.create_hash("password") ==
    {:error, "The password should contain at least one number and one punctuation character."}

    assert Comeonin.create_hash("pa$w0rd") ==
    {:error, "The password should be at least 8 characters long."}

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
    {:error, ~s(We could not find the password. The password key should be either :password or "password".)}
  end

  test "create user map with no check for punctuation characters or digits" do
    {:ok, params} = %{"name" => "joe", "password" => "gooseberries"}
              |> Comeonin.create_user([extra_chars: false])
    assert Map.has_key?(params, "password_hash")
    refute Map.has_key?(params, "password")
  end

  test "create user map error" do
    assert %{"name" => "joe", "password" => "gooseberries"} |> Comeonin.create_user ==
    {:error, "The password should contain at least one number and one punctuation character."}
  end

end
