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

  ## Adjusting the speed / complexity of bcrypt and pbkdf2

  Both bcrypt and pbkdf2 are designed to be computationally intensive and
  slow. This limits the number of attempts an attacker can make within a
  certain time frame. In addition, they can be configured to run slower,
  which can help offset some of the hardware improvements made over time.

  In the case of bcrypt, the number of log_rounds can be increased to make
  it more complex, and slower. The minimum number is 4 and the maximum is
  31. The default is 12.
  
  As for pbkdf2, the number of rounds can be increased to make it slower.
  The maximum number of rounds is 4294967295 and the default is 40000.

  It is recommended to make the function as slow as possible, balancing
  the inconvenience to the user with security considerations. To help
  you make this decision, this module provides timing functions for
  bcrypt and pbkdf2.
  """

  @doc """
  A function to help the developer decide how many log_rounds to use
  when using bcrypt.
  """
  def time_bcrypt(log_rounds \\ 12) do
    {time, _} = :timer.tc(Comeonin.Bcrypt, :hashpwsalt, ["password", log_rounds])
    IO.puts "Rounds: #{log_rounds}, Time: #{time / 1000} ms"
  end

  @doc """
  A function to help the developer decide how many rounds to use
  when using pbkdf2.
  """
  def time_pbkdf2(rounds \\ 40000) do
    {time, _} = :timer.tc(Comeonin.Pbkdf2, :hashpwsalt, ["password", 16, rounds])
    IO.puts "Rounds: #{rounds}, Time: #{time / 1000} ms"
  end
end
