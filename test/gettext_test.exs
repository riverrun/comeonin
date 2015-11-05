defmodule GettextTest do
  use ExUnit.Case, async: true
  import Comeonin.Gettext

  test "gettext works with Japanese po file" do
    Gettext.put_locale(Comeonin.Gettext, "ja_JP")
    text =  gettext "The password should be at least %{min_len} characters long.", min_len: 8
    assert text == "パスワードは8文字以上である必要があります。"
  end

  test "gettext returns Japanese message if locale is ja_JP" do
    Gettext.put_locale(Comeonin.Gettext, "ja_JP")

    assert Comeonin.create_hash("password") ==
    {:error, "パスワードは1字以上の数字と記号が含まれている必要があります。"}

    assert Comeonin.create_hash("pa$w0rd") ==
    {:error, "パスワードは8文字以上である必要があります。"}
  end
end
