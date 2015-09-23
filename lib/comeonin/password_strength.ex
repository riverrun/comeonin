defmodule Comeonin.PasswordStrength do
  @moduledoc """
  Module to check password strength.

  # Password security and usability

  The following two sections will provide information about password strength
  and user attitudes to password guidelines.

  If you are checking password strength and not allowing passwords because
  they are too weak, then you need to take the users' attitudes into account.
  If the users find the process of creating passwords too difficult, they
  are likely to find ways of bending the rules you set, and this might have
  a negative impact on password security.

  ## Creating strong passwords

  Strong passwords are passwords that are difficult for a potential attacker to
  guess or work out. The strength of a password depends on a combination
  of the following:

    * how random it is
    * its length
    * the size of its character set

  An attacker is likely to start an attempt to break a password by using
  common words and common patterns, like sequences and repetitions. With
  a truly random password, this kind of attack would not be possible,
  which means that the attacker would have to resort to a more costly
  brute force attack. However, this raises a usability issue as random
  passwords are very difficult for people to create and remember. One
  way of dealing with this issue is to use computer-generated random
  passwords and for the user to write them down or use a password
  manager.

  The term entropy is often used to refer to the number of combinations
  that a password with a certain character set, and a certain length,
  would have. The larger the character set and the longer the password
  is, the greater the entropy. This is why users are often encouraged
  to write long passwords that contain digits or punctuation characters.
  Entropy is related to password strength, and a password with a higher
  entropy is usually stronger than one with a lower entropy. However,
  as mentioned in the previous paragraph, if the password contains
  predictable patterns, the lack of randomness will make it weaker.

  Finally, passwords should not be shared as this makes them weaker,
  just as in the case when any secret is shared between multiple people.

  ## User attitudes and password security

  It is becoming more and more impractical for users to remember the
  many passwords they need, especially as it is recommended that they
  use a different, strong (difficult to remember) password for each
  service. As a result, it is likely that many users will choose to
  either use the same password for many services, or use weaker,
  easy to remember passwords.

  One solution to this problem is to have users write down their
  passwords. The obvious problem with this solution is that the
  password can be stolen. It is therefore important that the user
  keeps the password in a safe place and treats its loss seriously.

  Another solution is for the users to use password managers.
  This is a valid solution as long as the password managers themselves
  are secure. See [Security of password managers]
  (https://www.schneier.com/blog/archives/2014/09/security_of_pas.html)
  for more information.

  ## Further information

  Visit our [wiki](https://github.com/elixircnx/comeonin/wiki)
  for links to further information about these and related issues.

  """

  import Comeonin.PasswordStrength.Substitutions

  @digits String.codepoints("0123456789")
  @punc String.codepoints(" !#$%&'()*+,-./:;<=>?@[\\]^_{|}~\"")
  @common Path.join([__DIR__, "password_strength", "10k_6chars.txt"])
  |> File.read! |> String.split("\n") |> Enum.into(HashSet.new)

  @doc """
  Check the strength of the password.

  ## Options

  There are three options:

    * min_length -- minimum allowable length of the password
    * extra_chars -- check for punctuation characters (including spaces) and digits
    * common -- check to see if the password is too common (easy to guess)

  The default value for `min_length` is 8 characters if `extra_chars` is true,
  but 12 characters is `extra_chars` is false. `extra_chars` and `common` are
  true by default.

  ## Common passwords

  If the password is found in the list of common passwords, then this function
  will return a message saying that it is too easy to guess because it is
  common. This check will also check variations of the password with some
  of the characters substituted. For example, for the common password `password`,
  the words `P@$5w0Rd`, `p455w0rd`, `pA$sw0rD` (and many others) will also be checked.

  The user's password will also be checked with the first and / or last letter
  removed. For example, the words `(p@$swoRd`, `p4ssw0rD3` and `^P455woRd9`
  would also not be allowed as they are too similar to `password`.

  ## Examples

  This example will check that the password is at least 8 characters long,
  it contains at least one punctuation character and one digit, and it is
  not similar to any word in the list of common passwords.

      Comeonin.PasswordStrength.strong_password?("7Gr$cHs9")

  The following example will check that the password is at least 16 characters
  long and will not check for punctuation characters or digits.

      Comeonin.PasswordStrength.strong_password?("verylongpassword", [min_length: 16, extra_chars: false])

  """
  def strong_password?(password, opts \\ []) do
    common = Keyword.get(opts, :common, true)
    {min_len, extra_chars} = case Keyword.get(opts, :extra_chars, true) do
      true -> {Keyword.get(opts, :min_length, 8), true}
      _ -> {Keyword.get(opts, :min_length, 12), false}
    end
    case pass_length?(String.length(password), min_len) do
      true -> further_checks(extra_chars, common, password)
      message -> message
    end
  end

  defp further_checks(false, false, _password), do: true
  defp further_checks(false, true, password), do: common_pword?(password)
  defp further_checks(true, false, password), do: has_punc_digit?(password)
  defp further_checks(true, true, password) do
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
    if all_candidates(password) |> Enum.any?(&Set.member?(@common, &1)) do
      "The password you have chosen is weak because it is easy to guess. Please choose another one."
    else
      true
    end
  end
end
