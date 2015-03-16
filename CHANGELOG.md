# Changelog

## 0.3.0 (2015-03-04)

* Enhancements
  * Updated bcrypt to version 1.5.2.

## v0.2.4 (2015-02-26)

* Enhancements
  * Added configuration options for number of log_rounds, or rounds.

## v0.2.2 (2015-01-25)

* Enhancements
  * Improved documentation about the recommended time the functions should take.
  * Increased default number of rounds for pbkdf2_sha512 from 40000 to 60000.
  * Improved implementation of dummy check.

* Changes
  * Removed the `salt_length` optional argument from `Comeonin.Pbkdf2.hashpwsalt`. The only optional argument to this function is now the number of rounds.

## v0.2.0 (2015-01-21)

* Enhancements
  * Added support for pbkdf2_sha512.
  * Added Travis integration.
  * Added timing functions to help developers adjust the complexity of the key derivation functions.

* Changes
  * Removed the hashing and check functions from the main Comeonin module.

## v0.1.1

* Bug fixes
  * Enable build on OS X.

## v0.1.0

* Bcrypt authentication.
