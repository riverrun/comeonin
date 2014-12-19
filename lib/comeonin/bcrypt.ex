defmodule Comeonin.Bcrypt do

  def gen_salt do
    {:ok, salt} = :bcrypt.gen_salt()
    salt
  end

  def hash_password(password, salt) do
    password = String.to_char_list(password)
    {:ok, hash} = :bcrypt.hashpw(password, salt)
    :erlang.list_to_binary(hash)
  end

  def check_password(password, stored_hash) do
    password = String.to_char_list(password)
    {:ok, hash} = :bcrypt.hashpw(password, stored_hash)
    :erlang.list_to_binary(hash) == stored_hash
  end

end
