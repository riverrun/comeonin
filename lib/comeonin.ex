defmodule Comeonin do
  @moduledoc """
  Module to make authorization of users more straightforward.

  At the moment, this just supports Bcrypt.
  """

  alias Comeonin.Bcrypt

  @doc """
  Hash the password.
  """
  def hash_password(password, log_rounds \\ 10) do
    salt = Bcrypt.gensalt(log_rounds)
    Bcrypt.hashpw(password, salt)
  end

  @doc """
  Check the password.
  """
  def check_password(password, stored_hash) do
    Bcrypt.checkpw(password, stored_hash)
  end
  def check_password, do: Bcrypt.checkpw

  @doc """
  This is a convenience function to check the password of a user
  from a database (ecto) query.

  ##Example use

      def login(username, password) do
        query = from user in Coolapp.User,
                where: user.username == ^username,
                select: user
        newuser = Coolapp.Repo.one(query)
        Comeonin.check_user(password, newuser)
      end

  In the above example, `Coolapp.User` needs to have an entry for `password`.
  The `username` also needs to be unique.
  """
  def check_user(password, user) when is_map(user) do
    if Map.has_key?(user, :password) do
      Bcrypt.checkpw(password, user.password)
    else
      Bcrypt.checkpw
    end
  end
  def check_user(_, _), do: Bcrypt.checkpw
end
