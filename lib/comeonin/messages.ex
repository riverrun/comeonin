defmodule Comeonin.Messages do
  @moduledoc """
  Messages that can be translated.

  These messages can be translated if you have the `comeonin_i18n`
  app installed.

  If you do not have the `comeonin_i18n` app installed, the standard
  English messages will be used.
  """

  if Code.ensure_loaded?(ComeoninI18n) do
    
    def pass_too_short(min_len), do: ComeoninI18n.pass_too_short(min_len)

    def pass_no_extra_chars, do: ComeoninI18n.pass_no_extra_chars

    def weak_pass, do: ComeoninI18n.weak_pass

  else

    def pass_too_short(min_len) do
      "The password should be at least #{min_len} characters long."
    end

    def pass_no_extra_chars do
      "The password should contain at least one number and one punctuation character."
    end

    def weak_pass do
      "The password you have chosen is weak because it is easy to guess. Please choose another one."
    end
  end
end
