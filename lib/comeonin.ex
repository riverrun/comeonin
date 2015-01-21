defmodule Comeonin do
  @moduledoc """
  Module to make authorization of users more straightforward.

  Comeonin supports bcrypt and pbkdf2_sha512.

  ## Use

  Import, or alias, the algorithm you want to use -- either `Comeonin.Bcrypt`
  or `Comeonin.Pbkdf2`.

  To hash a password with the default options:

      hash = hashpwsalt("difficult2guess")

  See each module's documentation for more information about
  all the available options.

  To check a password against the stored hash, use the `checkpw`
  function. This takes two arguments: the plaintext password and
  the stored hash:

      checkpw(password, stored_hash)

  There is also a `dummy_checkpw` function, which takes no arguments
  and is to be used when the username cannot be found. It performs a hash,
  but then returns false. This can be used to make user enumeration more
  difficult.
  """

  @doc """
  A function to help the developer decide how many log_rounds to use
  when using bcrypt. A higher number of rounds will increase the
  computational complexity of the bcrypt hashing function and will
  therefore make it slower.
  """
  def time_bcrypt(log_rounds \\ 12) do
    {time, _} = :timer.tc(Comeonin.Bcrypt, :hashpwsalt, ["password", log_rounds])
    IO.puts "Rounds: #{log_rounds}, Time: #{time} ms"
  end

  @doc """
  A function to help the developer decide how many rounds to use
  when using pbkdf2. A higher number of rounds will increase the
  computational complexity of the key derivation function and will
  therefore make it slower.
  """
  def time_pbkdf2(rounds \\ 40000) do
    {time, _} = :timer.tc(Comeonin.Pbkdf2, :hashpwsalt, ["password", 16, rounds])
    IO.puts "Rounds: #{rounds}, Time: #{time} ms"
  end
end
