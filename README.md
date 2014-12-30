##Comeonin

Password authorization (bcrypt, etc.) library for Elixir.

###Features / subjects for discussion

This library is intended to make it very straightforward for developers
to authorize users in as secure a manner as possible.

At the moment, Comeonin only supports bcrypt, and that might be the
only hashing scheme that we do support. However, we might also support
any of the following schemes if there is any demand for them.

* sha512_crypt
* pbkdf2_sha512
* scrypt

## Installation

1. Add comeonin to your `mix.exs` dependencies

  ```elixir
  defp deps do
    [ {:comeonin, github: "elixircnx/comeonin"} ]
  end
  ```

2. List `:comeonin` as an application dependency

  ```elixir
  def application do
    [applications: [:logger, :comeonin]]
  end
  ```

3. Run `mix do deps.get, compile`

###Usage

There are functions to generate a salt `Comeonin.Bcrypt.gen_salt`
and then use that salt to hash a password `Comeonin.Bcrypt.hashpw`, but there are
also the following two convenience functions (with examples):

* hashpwsalt -- generate a salt and then use that salt to hash a password

    hash = Comeonin.hashpwsalt("hard2guess")

* checkpw -- check the password against the stored hash

    Comeonin.checkpw("hard2guess", stored_hash)

This will return `true` if the password is correct, and `false` if
the password is wrong.

There is also an experimental `check_user` function, which can work
with the output from an ecto query.
