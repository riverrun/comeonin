# Changelog

## v0.3.0-dev

* Enhancements
  * Improved documentation about the recommended time the functions should take.

* Changes
  * Removed the `salt_length` optional argument from `Comeonin.Pbkdf2.hashpwsalt`. The only optional argument to this function is now the number of rounds.

## v0.2.0 (2015-01-21)

* Enhancements
  * Added support for pbkdf2_sha512.
  * Added timing functions to help developers adjust the complexity of the key derivation functions.

* Changes
  * Removed the hashing and check functions from the main Comeonin module.

## v0.1.1

* Bug fixes
  * Enable build on OS X.

## v0.1.0

* Bcrypt authentication.
