defmodule ComeoninI18nTest do
  use ExUnit.Case, async: true
  import Comeonin.Password

  test "gettext returns English message for default locale" do
    assert strong_password?("password") ==
    "The password should contain at least one number and one punctuation character."
  end

  test "gettext returns Japanese message if locale is ja_JP" do
    Gettext.put_locale(ComeoninI18n.Gettext, "ja_JP")

    assert strong_password?("password") ==
    "パスワードは1字以上の数字と記号が含まれている必要があります。"

    assert strong_password?("7$gI*w") ==
    "パスワードは8文字以上である必要があります。"

    assert strong_password?("P45$w0rd") ==
    "入力されたパスワードは推測が容易で強度が不十分です。違うものを指定してください。"
  end

  test "gettext returns German message if locale is de_DE" do
    Gettext.put_locale(ComeoninI18n.Gettext, "de_DE")

    assert strong_password?("password") ==
    "Das Kennwort sollte mindestens eine Ziffer und ein Satzzeichen enthalten."

    assert strong_password?("7$gI*w") ==
    "Das Kennwort sollte mindestens 8 Zeichen lang sein."
  end

end
