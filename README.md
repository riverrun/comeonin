##Comeonin

Password authorization (bcrypt, etc.) library for Elixir.

###Features

This library is intended to make authorizing users more straightforward.

At the moment, it only supports bcrypt.

In the future, we might also support sha512_crypt, pbkdf2_sha512,
and / or scrypt, depending on demand.

###Usage

Add comeonin to your `mix.exs` dependencies:

  defp deps do
    [
      {:comeonin, github: "elixircnx/comeonin"}
    ]
  end

List `:comeonin` as an application dependency

Run `mix do deps.get, compile`

####License

MIT
