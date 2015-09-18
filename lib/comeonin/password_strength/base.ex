defmodule Comeonin.PasswordStrength.Base do
  @moduledoc """
  Module to generate random passwords and check password strength.

  The function to check password strength checks that it is long enough
  and contains at least one digit and one punctuation character.

  # Password policy

  The guidelines below are mainly intended for any business, or organization,
  that needs to create and implement a password policy. However, much of the
  advice is also applicable to other users.

  ## Writing down passwords -- ADD SOMETHING ABOUT PASSWORD MANAGERS HERE

  Opinion seems to be divided on this matter, with several authors
  arguing that remembering multiple strong passwords can be very difficult
  for many users, and if users are forced to remember passwords,
  they are likely to create weaker passwords that are easier to remember
  as a result.

  If users are allowed to write down passwords, they should keep the
  password in a safe place and treat its loss seriously, that is, as
  seriously as the loss of an id card or a bank card.

  ## Password strength -- MENTION XKCD METHOD

  Strong passwords should:

    * be long
    * contain as large a character set as possible (digits, punctuation characters, etc.)
    * not contain dictionary words (this applies to multiple languages, not just English)
    * be kept secret (not shared between multiple users)

  If a password fails to meet any of the above criteria, then that makes it
  easier for programs to guess the password. It is important, therefore,
  that you try to ensure that all of the above criteria are met.

  ## Password length -- COMMON OPTION (MAYBE THIS WILL BE DEFAULT, NOT AN OPTION)

  Ideally, the password should be as long as possible. However, many users
  would not be happy if they had to type in passwords 20 or 30 characters
  long every time they had to access a service (although this might be
  justifiable in certain cases), and so there needs to be a balance struck
  between usability and the ideal password length. Please read the section
  `User compliance` below for information about why usability is such
  an important consideration.

  In this module, the default length of the randomly generated passwords
  is 12 characters, and with the `strong_password?` function, the minimum
  length of passwords is 8 characters. Both of these values can be changed
  in the config file.

  With bcrypt, the maximum password length is 72 characters. Longer passwords
  can be used, but the extra characters (after the 72nd character) are ignored.

  ## Creating strong passwords -- DO WE WANT THIS FIRST PARAGRAPH

  For passwords that need to be remembered, creating a password by using
  the first or second letter of each word in an uncommon phrase can be
  a way of creating a strong password which is also easy to remember.

  For passwords that do not need to be remembered, that can be written
  down, generating passwords programmatically seems to be the best option,
  as computer programs are generally better than humans at creating
  random passwords.

  ## User compliance -- GET MORE INFO ABOUT THIS!!!

  One major theme in the research on password policies is the difficulty
  of getting users to comply with the guidelines. It seems that if users
  find it difficult to follow the rules for creating, remembering and using
  passwords, then they will find creative ways of breaking the rules to
  make it easier to get their work done.

  This question of user compliance is an issue that needs to be taken
  into serious consideration when formulating any password policy,
  especially as a user not following the rules can have a serious
  impact on the security of the rest of the organization.

  ## Further information

  Visit our wiki (https://github.com/elixircnx/comeonin/wiki)
  for links to further information about these and related issues.

  """

  alias Comeonin.PasswordStrength.Substitutions

  @digits String.codepoints("0123456789")
  @punc String.codepoints(" ,./!@#$%^&*();:?<>")
  @common Path.join(__DIR__, "10k_6chars.txt")
  |> File.read! |> String.split("\n") |> Enum.into(HashSet.new)

  @doc """
  Check the strength of the password.

  There are two options: min_length and extra_chars.
  min_length checks that the password is not shorter than the minimum length.
  extra_chars checks that the password contains at least one digit and one
  punctuation character (spaces are counted as punctuation characters).

  extra_chars is true by default, and min_length's default is 8 characters
  if extra_chars is set to true, but 12 characters if extra_chars is set to false.

  ## Examples

  This example will check that the password is at least 8 characters long and
  will check that it contains at least one punctuation character and one digit.

      Comeonin.PasswordStrength.Base.strong_password?("pa$$w0rd")

  The following example will check that the password is at least 16 characters
  long and will not check for punctuation characters or digits.

      Comeonin.PasswordStrength.Base.strong_password?("verylongpassword", [min_length: 16, extra_chars: false])

  """
  def strong_password?(password, opts \\ []) do
    {min_len, extra_chars} = case Keyword.get(opts, :extra_chars, true) do
      true -> {Keyword.get(opts, :min_length, 8), true}
      _ -> {Keyword.get(opts, :min_length, 12), false}
    end
    case pass_length?(String.length(password), min_len) do
      true -> further_checks(extra_chars, password)
      message -> message
    end
  end

  defp further_checks(false, password), do: common_pword?(password)
  defp further_checks(true, password) do
    case has_punc_digit?(password) do
      true -> common_pword?(password)
      message -> message
    end
  end

  defp pass_length?(word_len, min_len) when word_len < min_len do
    "The password should be at least #{min_len} characters long."
  end
  defp pass_length?(_, _), do: true

  defp has_punc_digit?(word) do
    if :binary.match(word, @digits) != :nomatch and :binary.match(word, @punc) != :nomatch do
      true
    else
      "The password should contain at least one number and one punctuation character."
    end
  end

  defp common_pword?(password) do
    if Substitutions.get_candidates(password) |> Enum.any?(&Set.member?(@common, &1)) do
      "The password you have chosen is weak because it is easy to guess. Please choose another one."
    else
      true
    end
  end
end
