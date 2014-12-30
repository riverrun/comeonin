defmodule Comeonin do
  @moduledoc """
  Module to make authorization of users more straightforward.

  At the moment, this just supports Bcrypt.
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
  Check the password.

  The password should be an Elixir string.
  """
  def checkpw(password, stored_hash) do
    Bcrypt.checkpw(password, stored_hash)
  end
  def checkpw, do: Bcrypt.checkpw

  @doc """
  This is a convenience function to check the password of a user
  from a database (ecto) query.

  ##Example use

      def login(username, password) do
        query = from user in Coolapp.User,
                where: user.username == ^username,
                select: user
        Coolapp.Repo.one(query) |> Comeonin.check_user(password)
      end

  In the above example, `Coolapp.User` needs to be a map or struct,
  and it must have an entry for `password`.
  The `username` also needs to be unique.
  """
  def check_user(user, password) when is_map(user) do
    if Map.has_key?(user, :password) do
      if Bcrypt.checkpw(password, user.password) == true do
        user
      else
        nil
      end
    else
      Bcrypt.checkpw
      nil
    end
  end
  def check_user(_, _) do
    Bcrypt.checkpw
    nil
  end
end
