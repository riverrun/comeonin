# Changelog

## 5.3.0

* Changes
  * changed `add_hash` so that it does NOT set the password to nil

## 5.2.0

* Enhancements
  * updated documentation for the Comeonin module

## 5.1.0

* Enhancements
  * add a behaviour_test module to be used by implementations of the Comeonin behaviours

## 5.0.0

* Enhancements
  * updated Comeonin to be a specification for password hashing libraries
    * it offers the Comeonin and Comeonin.PasswordHash behaviours

## 4.1.2

* Bug fixes
  * made sure that the `hash_key` option is used if present

## 4.1.1

* Changes
  * changed `check_pass` with statement to case - in an attempt to suppress dialyzer warnings

## 4.1.0

* Enhancements
  * added `hash_key` option to `check_pass`
    * as with version 4.0, `check_pass` will use `:password_hash` / `:encrypted_password` if present

## 4.0.0

* Enhancements
  * Added support for Argon2 (as an optional dependency - argon2_elixir)
  * Added higher-level helper functions to each algorithm's module
    * These functions accept / return maps and should reduce code use when adding password hashes / checking passwords
  * Improved the statistics function in each module - `report`
* Changes
  * Made all the hashing algorithms optional dependencies
  * Moved the configuration to the separate dependency libraries
  * Removed support for one-time passwords
    * This is now a separate library - OneTimePassEcto ("https://github.com/riverrun/one_time_pass_ecto")

## 3.2.0

* Bug fixes
  * Shortening user-supplied salts to 128 bits - making it compatible with other implementations

## 3.1.0

* Changes
  * Now forcing a recompile of C code for Windows users

## 3.0.0

* Enhancements
  * Small changes to NIF code to make it more scheduler-friendly
  * Improved documentation with respect to Argon2
* Changes
  * Now using `elixir_make` to help compile the C code

## 2.6.0

* Enhancements
  * Improved Windows build to prevent build failure when upgrading Erlang versions

## 2.4.0

* Enhancements
  * Improved Windows build error messages
* Changes
  * Changed behavior for incorrect input to Bcrypt.gen_salt

## 2.3.0

* Enhancements
  * Added support for one-time passwords (HOTP, TOTP) for use in two factor authentication

## 2.2.0

* Changes
  * Improved documentation for Windows builds
  * Updated the required Elixir version to 1.2

## 2.1.0

* Enhancements
  * Added legacy option to Comeonin.Bcrypt.gen_salt so that hashes with the older $2a$ prefix can be more easily generated
  * To try to solve the load errors after upgrading Erlang / Elixir:
    * Force C code to be recompiled every time `deps.compile` is called
    * Added basic upgrade function to the NIF library
  * To be compatible with the nerves project:
    * Added CROSSCOMPILE option to the Makefile
    * Stopped the library autoloading on compilation (requires Elixir 1.2.2)

## 2.0.0 (2015-12-17)

* Changes
  * Increased the default number of rounds for pbkdf2_sha512 to 100_000
  * Removed `create_hash` and `create_user` functions
  * Moved the password strength checker and random password generator to a separate package, called NotQwerty123
    * This means that i18n support has been moved to NotQwerty123

## 1.6.0 (2015-11-17)

* Changes
  * Edited C code and deleted unused functions

## 1.5.0 (2015-11-10)

* Changes
  * Moved gettext support to `comeonin_i18n` optional dependency
  * Removed forced compilation of C code in dev and prod environments

## 1.4.0 (2015-11-06)

* Enhancements
  * Added gettext support
  * Added Japanese translations for messages

## 1.3.0 (2015-10-18)

* Enhancements
  * Improved the efficiency of the common password check for the `strong_password` function
  * Added more information to the Mix build errors
* Changes
  * Forcing compilation of C code in dev and prod environments

## 1.2.0 (2015-09-26)

* Enhancements
  * Added a common option to the `strong_password` check. This checks for passwords that are easy to guess, or common
  * Improved random password generator - added a check to ensure it is strong and set the minimum length to 8 characters

## 1.1.4 (2015-09-25)

* Bug fix
  * Removed `random_bytes` function. Now calling :crypto.strong_rand_bytes directly

## 1.1.0 (2015-07-28)

* Changes
  * Divided the `strong password` check into two parts: minimum length and check for punctuation
  characters and digits
  * Removed configuration values for password length for generated passwords and minimum length of passwords
  for the password check

## 1.0.5 (2015-07-14)

* Bug fix
  * Replaced `Mix.Shell.info` with `IO.binwrite` to prevent compile errors with certain character encodings

## 1.0.1 (2015-05-31)

* Enhancements
  * Enabled the create_user function to be used with atoms as keys as well as strings

## 1.0.0 (2015-05-20)

* Changes
  * Renamed signup_user, function to check password strength before hashing the password, to create_user
* Enhancements
  * Added create_user function which takes a map, removes the "password" entry and adds a "password_hash" entry

## 0.11.0 (2015-05-19)

* Changes
  * Renamed hashpwsalt/2 to signup_user/1

## 0.10.0 (2015-05-14)

* Changes
  * Removed log_rounds, or rounds, parameter for the function hashpwsalt
  * Added option to check password (for strength) in the function hashpwsalt (hashpwsalt/2)

## 0.9.0 (2015-05-08)

* Enhancements
  * Added random password generator
  * Added optional check to test if passwords have digits and punctuation characters
* Bug fixes
  * Added information about password strength and password policies to the documentation

## 0.8.2 (2015-05-02)

* Bug fixes
  * Updated Windows build and improved error information at compile time

## 0.8.0 (2015-04-20)

* Bug fixes
  * Updated bcrypt to support non-ascii characters in the password (pbkdf2 already supports these characters)

## 0.7.0 (2015-04-18)

* Enhancements
  * Use crypto.strong_rand_bytes by default for generating random numbers

## 0.6.0 (2015-04-17)

* Enhancements
  * Updated bcrypt implementation to only call C functions for the most expensive operations

## 0.5.0 (2015-04-14)

* Enhancements
  * Updated bcrypt implementation so that long-running NIFs are cut to a minimum

## 0.4.0 (2015-04-05)

* Enhancements
  * Updated pbkdf2_sha512 to prevent users from calling `hashpass` without a salt

## 0.3.0 (2015-03-04)

* Enhancements
  * Updated bcrypt to version 1.5.2

## v0.2.4 (2015-02-26)

* Enhancements
  * Added configuration options for number of log_rounds, or rounds

## v0.2.2 (2015-01-25)

* Enhancements
  * Improved documentation about the recommended time the functions should take
  * Increased default number of rounds for pbkdf2_sha512 from 40000 to 60000
  * Improved implementation of dummy check

* Changes
  * Removed the `salt_length` optional argument from `Comeonin.Pbkdf2.hashpwsalt`. The only optional argument to this function is now the number of rounds

## v0.2.0 (2015-01-21)

* Enhancements
  * Added support for pbkdf2_sha512
  * Added Travis integration
  * Added timing functions to help developers adjust the complexity of the key derivation functions

* Changes
  * Removed the hashing and check functions from the main Comeonin module

## v0.1.1

* Bug fixes
  * Enable build on OS X

## v0.1.0

* Bcrypt authentication
