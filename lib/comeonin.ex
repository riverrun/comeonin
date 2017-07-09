defmodule Comeonin do
  @moduledoc """
  Comeonin is a password hashing library that aims to make the
  secure validation of passwords as straightforward as possible.

  It also provides extensive documentation to help
  developers keep their apps secure.

  Comeonin supports argon2, bcrypt and pbkdf2 (sha512 and sha256).

  ## Installation

  First, you need to decide which algorithm to use (see the
  `Choosing an algorithm` section for more information about
  each algorithm):

    * argon2 - [argon2_elixir](https://github.com/riverrun/argon2_elixir)
    * bcrypt - [bcrypt_elixir](https://github.com/riverrun/bcrypt_elixir)
    * pbkdf2 - [pbkdf2_elixir](https://github.com/riverrun/pbkdf2_elixir)

  Then add `comeonin` and the library you choose to the `deps` section
  of your `mix.exs` file, as in the following example.

      defp deps do
        [
          {:comeonin, "~> 3.0"},
          {:argon2_elixir, "~> 1.0"},
        ]
      end

  ## Use

  This module offers three functions: `create_hash`, `add_hash` and `check_pass`.

  ## Choosing an algorithm

  The algorithms Argon2, Bcrypt and Pbkdf2 are all very strong password hashing
  functions.

  Argon2 is a lot newer, and this can be considered to be both an advantage
  and a disadvantage. On the one hand, Argon2 benefits from more recent
  research. On the other hand, Argon2 has not received the same amount
  of scrutiny that Bcrypt / Pbkdf2 has.

  ### Argon2

  Argon2 is the winner of the [Password Hashing Competition (PHC)](https://password-hashing.net).

  Argon2 is a memory-hard password hashing function which can be used to hash
  passwords for credential storage, key derivation, or other applications.

  Being memory-hard means that it is not only computationally expensive,
  but it also uses a lot of memory (which can be configured). This means
  that it is much more difficult to attack Argon2 hashes using GPUs or
  dedicated hardware.

  More information is available at the [Argon2 reference C implementation
  repository](https://github.com/P-H-C/phc-winner-argon2)

  ### Bcrypt

  Bcrypt is a key derivation function for passwords designed by Niels Provos
  and David Mazières. Bcrypt is an adaptive function, which means that it can
  be configured to remain slow and resistant to brute-force attacks even as
  computational power increases.

  The computationally intensive code is run in C, using Erlang NIFs. One concern
  about NIFs is that they block the Erlang VM, and so it is better to make
  sure these functions do not run for too long. This bcrypt implementation
  has been adapted so that each NIF runs for as short a time as possible.

  ### Pbkdf2

  Pbkdf2 is a password-based key derivation function
  that uses a password, a variable-length salt and an iteration
  count and applies a pseudorandom function to these to
  produce a key.

  The original implementation used SHA-1 as the pseudorandom function,
  but this version uses HMAC-SHA-512, the default, or HMAC-SHA-256.

  ## Further information

  Visit our [wiki](https://github.com/riverrun/comeonin/wiki)
  for links to further information about these and related issues.
  """

  @doc """
  Generate a password hash.

  First, a random salt is generated, and then the password and salt
  are hashed using the crypto module you choose.

  For more information about the available options, see the documentation
  for the crypto module's `hash_pwd_salt` function.
  """
  def create_hash(password, crypto, opts \\ []) do
    crypto.hash_pwd_salt(password, opts)
  end

  @doc """
  Add the password hash to a map and set the password to nil.

  ## Examples

  In the following example, this function is used with an Ecto changeset:

      defp put_pass_hash(%Ecto.Changeset{valid?: true, changes:
          %{password: password}} = changeset) do
        change(changeset, Comeonin.add_hash(password))
      end
      defp put_pass_hash(changeset), do: changeset
  """
  def add_hash(%{password: password}, crypto, opts \\ []) do
    %{password_hash: crypto.hash_pwd_salt(password, opts), password: nil}
  end

  @doc """
  Check the password by comparing its hash with a stored password hash,
  within a user struct, or map.

  After finding the password hash in the user struct, the `verify_hash`
  function is run to check the password. Then the function returns
  {:ok, user} or {:error, message}.

  If the first argument is nil, meaning that there is no user with that
  name, a dummy verify function is run to make user enumeration, using
  timing information, more difficult. This can be disabled by adding
  `hide_user: false` to the opts.

  For more information about the other available options, see the
  documentation for the crypto module's `verify_hash` function.
  """
  def check_pass(user, password, crypto, opts \\ [])
  def check_pass(nil, _password, crypto, opts) do
    unless opts[:hide_user] == false do
      crypto.no_user_verify(opts)
    end
    {:error, "invalid user-identifier"}
  end
  def check_pass(%{password_hash: hash} = user, password, crypto, opts) do
    crypto.verify_hash(hash, password, opts) and
    {:ok, user} || {:error, "invalid password"}
  end

end
