defmodule Comeonin.Password do
  @moduledoc """
  Module to generate random passwords and check password strength.

  The `gen_password` function generates a random password with letters,
  digits and punctuation characters.

  The `strong_password?` function checks that the password is long enough,
  it contains at least one digit and one punctuation character, and it is
  not similar to any common passwords.

  # Password security and usability

  The following two sections will provide information about password strength
  and user attitudes to password guidelines.

  If you are checking password strength and not allowing passwords because
  they are too weak, then you need to take the users' attitudes into account.
  If the users find the process of creating passwords too difficult, they
  are likely to find ways of bending the rules you set, and this might have
  a negative impact on password security.

  ## Password strength

  This section will look at how `guessability` and `entropy` relate to
  password strength.

  Guessability is how easy it is for a potential attacker to guess or
  work out what the password is. An attacker is likely to start an
  attempt to guess a password by using common words and common patterns,
  like sequences of characters or repeated characters. A password is strong
  if its guessability is low, that is, if it does not contain such predictable
  patterns.

  Entropy refers to the number of combinations that a password
  with a certain character set and a certain length would have. The
  larger the character set and the longer the password is, the greater
  the entropy. This is why users are often encouraged to write long
  passwords that contain digits or punctuation characters.

  Entropy is related to password strength, and a password with a higher
  entropy is usually stronger than one with a lower entropy. However,
  even if the entropy is high, a password is weak if its guessability
  is high.

  ## Password strength check

  In this module's `strong_password?` function, the option common
  is meant to keep the guessability low, and the options min_length
  and extra_chars seek to keep the entropy high.

  ## User attitudes and password security

  It is becoming more and more impractical for users to remember the
  many passwords they need, especially as it is recommended that they
  use a different, strong (often difficult to remember) password for
  each service. As a result, it is likely that many users will choose
  to either use the same password for many services, or use weaker,
  easy to remember passwords.

  One solution to this problem is to have users write down their
  passwords. The obvious problem with this solution is that the
  password can be stolen. It is therefore important that the user
  keeps the password in a safe place and treats its loss seriously.

  Another solution is for the users to use password managers.
  This is a valid solution as long as the password managers themselves
  are secure. See
  [Security of password managers](https://www.schneier.com/blog/archives/2014/09/security_of_pas.html)
  for more information.

  ## Further information

  Visit our [wiki](https://github.com/elixircnx/comeonin/wiki)
  for links to further information about these and related issues.

  """

  import Comeonin.Password.Common

  @alpha Enum.concat ?A..?Z, ?a..?z
  @alphabet '!#$%&\'()*+,-./:;<=>?@[\\]^_{|}~"' ++ @alpha ++ '0123456789'
  @char_map Enum.map_reduce(@alphabet, 0, fn x, acc ->
    {{acc, x}, acc + 1} end) |> elem(0) |> Enum.into(%{})

  @digits String.codepoints("0123456789")
  @punc String.codepoints(" !#$%&'()*+,-./:;<=>?@[\\]^_{|}~\"")

  @doc """
  Randomly generate a password.

  Users are often advised to use random passwords for authentication.
  However, creating truly random passwords is difficult for people to
  do well and is something that computers are usually better at.

  This function creates a random password that is guaranteed to contain
  at least one digit and one punctuation character.

  The default length of the password is 12 characters and the minimum
  length is 8 characters.
  """
  def gen_password(len \\ 12)
  def gen_password(len) when len > 7 do
    rand_password(len) |> to_string |> ensure_strong(len)
  end
  def gen_password(_) do
    raise ArgumentError, message: "The password should be at least 8 characters long."
  end

  defp rand_password(len) do
    case rand_numbers(len) |> punc_digit? do
      false -> rand_password(len)
      code -> for val <- code, do: Map.get(@char_map, val)
    end
  end
  defp rand_numbers(len) do
    for _ <- 1..len, do: :crypto.rand_uniform(0, 93)
  end
  defp punc_digit?(code) do
    Enum.any?(code, &(&1 < 31)) and Enum.any?(code, &(&1 > 82)) and code
  end

  defp ensure_strong(password, len) do
    case strong_password?(password) do
      true -> password
      _ -> gen_password(len)
    end
  end

  @doc """
  Check the strength of the password.

  ## Options

  There are three options:

    * min_length -- minimum allowable length of the password
    * extra_chars -- check for punctuation characters (including spaces) and digits
    * common -- check to see if the password is too common (easy to guess)

  The default value for `min_length` is 8 characters if `extra_chars` is true,
  but 12 characters if `extra_chars` is false. This is because the password
  should be longer if the character set is restricted to upper and lower case
  letters.

  `extra_chars` and `common` are true by default.

  ## Common passwords

  If the password is found in the list of common passwords, then this function
  will return a message saying that it is too weak because it is easy to guess.
  This check will also check variations of the password with some of the
  characters substituted. For example, for the common password `password`,
  the words `P@$5w0Rd`, `p455w0rd`, `pA$sw0rD` (and many others) will also
  be checked.

  The user's password will also be checked with the first and / or last letter
  removed. For example, the words `(p@$swoRd`, `p4ssw0rD3` and `^P455woRd9`
  would also not be allowed as they are too similar to `password`.

  ## Examples

  This example will check that the password is at least 8 characters long,
  it contains at least one punctuation character and one digit, and it is
  not similar to any word in the list of common passwords.

      Comeonin.Password.strong_password?("7Gr$cHs9")

  The following example will check that the password is at least 16 characters
  long and will not check for punctuation characters or digits.

      Comeonin.Password.strong_password?("verylongpassword", [min_length: 16, extra_chars: false])

  """
  def strong_password?(password, opts \\ []) do
    common = Keyword.get(opts, :common, true)
    {min_len, extra_chars} = case Keyword.get(opts, :extra_chars, true) do
      true -> {Keyword.get(opts, :min_length, 8), true}
      _ -> {Keyword.get(opts, :min_length, 12), false}
    end
    word_len = String.length(password)
    case pass_length?(word_len, min_len) do
      true -> further_checks(extra_chars, common, password, word_len)
      message -> message
    end
  end

  defp further_checks(false, false, _password, _word_len), do: true
  defp further_checks(false, true, password, word_len), do: not_common?(password, word_len)
  defp further_checks(true, false, password, _word_len), do: has_punc_digit?(password)
  defp further_checks(true, true, password, word_len) do
    case has_punc_digit?(password) do
      true -> not_common?(password, word_len)
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

  defp not_common?(password, word_len) when word_len < 13 do
    if password |> String.downcase |> common_password?(word_len) do
      "The password you have chosen is weak because it is easy to guess. Please choose another one."
    else
      true
    end
  end
  defp not_common?(_, _), do: true
end
