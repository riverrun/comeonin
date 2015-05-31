defmodule Comeonin do
  @moduledoc """
  Comeonin is a password hashing library that aims to make the
  secure validation of passwords as straightforward as possible.

  It also provides extensive documentation to help
  developers keep their apps secure.

  Comeonin supports bcrypt and pbkdf2_sha512.

  ## Use

  This module offers the following convenience functions:

    * create_hash -- check password strength before hashing it
    * create_user -- update a map with the password hash

  See the documentation for each function for more details.

  If you do not need this extra functionality, you can hash a password
  by using the `hashpwsalt` function -- using either Comeonin.Bcrypt or
  Comeonin.Pbkdf2.

  To hash a password with the default options:

      hash = hashpwsalt("difficult2guess")

  See each module's documentation for more information about
  all the available options.

  If you want more control over the generation of the salt, and, in
  the case of pbkdf2, the length of salt, you can use the `gen_salt`
  function and then pass the output to the `hashpass` function.

  To check a password against the stored hash, use the `checkpw`
  function. This takes two arguments: the plaintext password and
  the stored hash:

      checkpw(password, stored_hash)

  There is also a `dummy_checkpw` function, which takes no arguments
  and is to be used when the username cannot be found. It performs a hash,
  but then returns false. This can be used to make user enumeration more
  difficult. If an attacker already knows, or can guess, the username,
  this function will not be of any use, and so if you are going to use
  this function, it should be used with a policy of creating usernames
  that are not made public and are difficult to guess.

  ## Choosing an algorithm

  Bcrypt and pbkdf2_sha512 are both highly secure key derivation functions.
  They have no known vulnerabilities and their algorithms have been used
  and widely reviewed for at least 10 years. They are also designed
  to be `future-adaptable` (see the section below about speed / complexity
  for more details), and so we do not recommend one over the other.

  However, if your application needs to use a hashing function that has been
  recommended by a recognized standards body, then you will need to
  use pbkdf2_sha512, which has been recommended by NIST.

  ## Adjusting the speed / complexity of bcrypt and pbkdf2

  Both bcrypt and pbkdf2 are designed to be computationally intensive and
  slow. This limits the number of attempts an attacker can make within a
  certain time frame. In addition, they can be configured to run slower,
  which can help offset some of the hardware improvements made over time.

  It is recommended to make the key derivation function as slow as the
  user can tolerate. The actual recommended time for the function will vary
  depending on the nature of the application. According to the following NIST
  recommendations (http://csrc.nist.gov/publications/nistpubs/800-132/nist-sp800-132.pdf),
  having the function take several seconds might be acceptable if the user
  only has to login once every session. However, if an application requires
  the user to login several times an hour, it would probably be better to
  limit the hashing function to about 250 milliseconds.

  To help you decide how slow to make the function, this module provides
  convenience timing functions for bcrypt and pbkdf2.

  ## Further information

  Visit our wiki (https://github.com/elixircnx/comeonin/wiki)
  for links to further information about these and related issues.

  """

  alias Comeonin.Config
  alias Comeonin.Password

  @doc """
  A function to help the developer decide how many log_rounds to use
  when using bcrypt.

  The number of log_rounds can be increased to make the bcrypt hashing
  function more complex, and slower. The minimum number is 4 and the maximum is 31.
  The default is 12, but this is not necessarily the recommended number.
  The ideal number of log_rounds will depend on the nature of your application
  and the hardware being used.

  The `bcrypt_log_rounds` value can be set in the config file. See the
  documentation for `Comeonin.Config` for more details.
  """
  def time_bcrypt(log_rounds \\ 12) do
    salt = Comeonin.Bcrypt.gen_salt(log_rounds)
    {time, _} = :timer.tc(Comeonin.Bcrypt, :hashpass, ["password", salt])
    Mix.shell.info "Log rounds: #{log_rounds}, Time: #{div(time, 1000)} ms"
  end

  @doc """
  A function to help the developer decide how many rounds to use
  when using pbkdf2.

  The number of rounds can be increased to make the pbkdf2 hashing function slower.
  The maximum number of rounds is 4294967295. The default is 60_000, but this
  is not necessarily the recommended number. The ideal number of log_rounds
  will depend on the nature of your application and the hardware being used.

  The `pbkdf2_rounds` value can be set in the config file. See the
  documentation for `Comeonin.Config` for more details.
  """
  def time_pbkdf2(rounds \\ 60_000) do
    salt = Comeonin.Pbkdf2.gen_salt
    {time, _} = :timer.tc(Comeonin.Pbkdf2, :hashpass, ["password", salt, rounds])
    Mix.shell.info "Rounds: #{rounds}, Time: #{div(time, 1000)} ms"
  end

  @doc """
  This function can be used to check the strength of a password
  before hashing it. The password is then hashed only if the password is
  considered strong enough. For more details about password strength,
  read the documentation for the Comeonin.Password module.

  The default hashing algorithm is bcrypt, but this can be changed by
  setting the value of `crypto_mod` to `:pbkdf2` in the config file.
  """
  def create_hash(password, strength \\ true) do
    crypto_mod = Config.get_crypto_mod
    case strength and Password.strong_password?(password) do
      true -> {:ok, crypto_mod.hashpwsalt(password)}
      false -> {:ok, crypto_mod.hashpwsalt(password)}
      message -> {:error, message}
    end
  end

  @doc """
  This function takes a map with a password in it, removes the password
  and adds an entry for the password hash. This can be used after collecting
  user data and before adding it to the database.

  This uses the `create_hash` function, which can be used to check password
  strength before hashing it.

  When looking for the password, this function looks for a key which is either
  named "password" (a string) or :password (an atom). If it does not find
  either key, it will raise an error.

  As with the `create_hash` function, you can decide not to check password
  strength by setting the second argument to false.

  ## Examples

  All of the following will work ok:

      %{"name" => "fred", "password" => "&m@ng0es"} |> Comeonin.create_user

      %{name: "fred", password: "&m@ng0es"} |> Comeonin.create_user

      %{name: "fred", password: "123456"} |> Comeonin.create_user(false)

  The next example will raise an error because the key "password" or :password
  could not be found:

      iex> %{["name"] => "fred", ["password", "password_admin"] => "&m@ng0es"} |> Comeonin.create_user
      {:error, ~s(We could not find the password. The password key should be either :password or "password".)}

  This example will raise an error because the password is not long enough:

      iex> %{name: "fred", password: "123456"} |> Comeonin.create_user
      {:error, "The password should be at least 8 characters long."}

  """
  def create_user(user_params, strength \\ true)
  def create_user(%{password: password} = user_params, strength) do
    Map.delete(user_params, :password) |> create_map(password, :password_hash, strength)
  end
  def create_user(%{"password" => password} = user_params, strength) do
    Map.delete(user_params, "password") |> create_map(password, "password_hash", strength)
  end
  def create_user(_, _) do
    {:error, ~s(We could not find the password. The password key should be either :password or "password".)}
  end

  defp create_map(user_params, password, hash_key, strength) do
    case create_hash(password, strength) do
      {:ok, password_hash} -> {:ok, Map.put_new(user_params, hash_key, password_hash)}
      {:error, message} -> {:error, message}
    end
  end
end
