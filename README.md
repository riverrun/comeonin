##Comeonin

Password authorization (bcrypt, etc.) library for Elixir.

###Features / subjects for discussion

This library is intended to make authorizing users very straightforward.

At the moment, it only supports bcrypt, but in the future, we might also
support sha512_crypt, pbkdf2_sha512, and / or scrypt, depending on demand.

###Usage

Add comeonin to your `mix.exs` dependencies:

    defp deps do
        [
            {:comeonin, github: "elixircnx/comeonin"}
        ]
    end

List `:comeonin` as an application dependency

Run `mix do deps.get, compile`

The two most important functions are `hash_password` and `check_password`.

`hash_password` takes two arguments, the plaintext password and an optional
value for the number of rounds, which default to log 10:

    hash = Comeonin.hash_password("hard2guess")

`check_password` takes two arguments, the plaintext password and the
stored hash:

    Comeonin.check_password("hard2guess", stored_hash)

This will return `true` if the password is correct, and `false` if
the password is wrong.

There is also an experimental `check_user` function, which can work
with the output from an ecto query.

####License

MIT
