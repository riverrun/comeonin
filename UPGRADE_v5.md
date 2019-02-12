# Upgrading to version 5

1. remove `:comeonin` from the `deps` function in your mix.exs file.
2. update `:argon2_elixir` to version 2.0, `:bcrypt_elixir` to version 2.0,
or `:pbkdf2_elixir` to version 1.0.
3. using the conversion tables below, edit the hashing functions.

| Comeonin v4 | Comeonin v5 |
| :---------- | :---------- |
| Comeonin.Argon2.add_hash | Argon2.add_hash |
| Comeonin.Argon2.check_pass | Argon2.check_pass |
| Comeonin.Argon2.hashpwsalt | Argon2.hash_pwd_salt |
| Comeonin.Argon2.checkpw | Argon2.verify_pass |
| Comeonin.Argon2.dummy_checkpw | Argon2.no_user_verify |

| Comeonin v4 | Comeonin v5 |
| :---------- | :---------- |
| Comeonin.Bcrypt.add_hash | Bcrypt.add_hash |
| Comeonin.Bcrypt.check_pass | Bcrypt.check_pass |
| Comeonin.Bcrypt.hashpwsalt | Bcrypt.hash_pwd_salt |
| Comeonin.Bcrypt.checkpw | Bcrypt.verify_pass |
| Comeonin.Bcrypt.dummy_checkpw | Bcrypt.no_user_verify |

| Comeonin v4 | Comeonin v5 |
| :---------- | :---------- |
| Comeonin.Pbkdf2.add_hash | Pbkdf2.add_hash |
| Comeonin.Pbkdf2.check_pass | Pbkdf2.check_pass |
| Comeonin.Pbkdf2.hashpwsalt | Pbkdf2.hash_pwd_salt |
| Comeonin.Pbkdf2.checkpw | Pbkdf2.verify_pass |
| Comeonin.Pbkdf2.dummy_checkpw | Pbkdf2.no_user_verify |
