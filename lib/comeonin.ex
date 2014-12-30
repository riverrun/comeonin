defmodule Comeonin do
  @moduledoc """
  Module to make authorization of users more straightforward.

  At the moment, this just supports Bcrypt.

  There are functions for generating a salt with different numbers of
  rounds, and then using that salt to hash a password. However, most
  of the time, you will probably just need the `hashpwsalt` function,
  which takes one argument: the password (which must be a string).

  ##Example for hashing a password

      hash = Comeonin.hashpwsalt("difficult2guess")

  To check a password against the stored hash, use the `checkpw`
  function. This takes two arguments: the plaintext password and
  the stored hash.

  There is also a `dummy_checkpw` function which should be used
  when the username cannot be found. It performs a hash, but then
  returns false. This can be used to make user enumeration more
  difficult. This function takes no arguments, as in the example
  below, which shows how you might validate a user if you were
  using ecto.

  ##Example for checking a password

      def login(username, password) do
        query = from user in Coolapp.User,
                where: user.username == ^username,
                select: user
        Coolapp.Repo.one(query) |> check_login(password)
      end
      defp check_login(nil, _), do: Comeonin.dummy_checkpw
      defp check_login(user, password), do: Comeonin.checkpw(password, user.password)
  """

  alias Comeonin.Bcrypt

  @doc """
  Hash the password with a salt which is randomly generated.

  The password needs to be a string. Input of any other type
  will result in an error.
  """
  def hashpwsalt(password) do
    Bcrypt.hashpwsalt(password)
  end

  @doc """
  Check the password, which needs to be an Elixir string.

  The check is performed in constant time to avoid timing attacks.
  """
  def checkpw(password, stored_hash) do
    Bcrypt.checkpw(password, stored_hash)
  end

  @doc """
  Perform a dummy check for a user that does not exist.
  This always returns false. The reason for implementing this check is
  in order to make user enumeration by timing responses more difficult.
  """
  def dummy_checkpw, do: Bcrypt.dummy_checkpw
end
