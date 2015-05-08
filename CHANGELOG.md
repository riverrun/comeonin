# Changelog

## 0.9.0 (2015-05-08)

* Enhancements
  * Added random password generator.
  * Added optional check to test if passwords have digits and punctuation characters.
* Bug fixes
  * Added information about password strength and password policies to the documentation.

## 0.8.2 (2015-05-02)

* Bug fixes
  * Updated Windows build and improved error information at compile time.

## 0.8.0 (2015-04-20)

* Bug fixes
  * Updated bcrypt to support non-ascii characters in the password (pbkdf2 already supports these characters).

## 0.7.0 (2015-04-18)

* Enhancements
  * Use crypto.strong_rand_bytes by default for generating random numbers.

## 0.6.0 (2015-04-17)

* Enhancements
  * Updated bcrypt implementation to only call C functions for the most expensive operations.

## 0.5.0 (2015-04-14)

* Enhancements
  * Updated bcrypt implementation so that long-running NIFs are cut to a minimum.

## 0.4.0 (2015-04-05)

* Enhancements
  * Updated pbkdf2_sha512 to prevent users from calling `hashpass` without a salt.

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
