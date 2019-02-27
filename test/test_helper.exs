ExUnit.start()

defmodule Comeonin.TestHash do
  use Comeonin

  @impl true
  def hash_pwd_salt(password, _opts \\ []) do
    password
  end

  @impl true
  def verify_pass(password, hash) do
    password == hash
  end
end

defmodule Comeonin.FailHash do
  use Comeonin

  @impl true
  def hash_pwd_salt(password, _opts \\ []) do
    password
  end

  @impl true
  def verify_pass(password, hash) do
    password != hash
  end
end

defmodule Comeonin.OverrideHash do
  use Comeonin

  @impl true
  def add_hash(password, opts) do
    hash_key = opts[:hash_key] || :password_hash
    %{hash_key => hash_pwd_salt(password, opts), :password => "FILTERED"}
  end

  @impl true
  def check_pass(user, password, opts) do
    with {:ok, user} <- super(user, password, opts),
         do: {:ok, Map.drop(user, [:password_hash])}
  end

  @impl true
  def hash_pwd_salt(password, _opts \\ []) do
    password
  end

  @impl true
  def verify_pass(password, hash) do
    password == hash
  end
end
