defmodule Comeonin do
  @moduledoc """
  Module to make authorization of users more straightforward.

  Comeonin supports bcrypt and pbkdf2_sha512.

  ## Use

  Import the algorithm you want to use -- either `Comeonin.Bcrypt`
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
end
