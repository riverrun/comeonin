defmodule Comeonin do
  @moduledoc """
  Module to make authorization of users more straightforward.

  At the moment, this just supports Bcrypt.
  """

  alias Comeonin.Bcrypt

  def hash_password(password) do
    salt = Bcrypt.gen_salt
    Bcrypt.hash_password(password, salt)
  end

  def check_password(password, stored_hash) do
    Bcrypt.check_password(password, stored_hash)
  end
end
