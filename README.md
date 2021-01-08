# Comeonin

[![Build Status](https://travis-ci.com/riverrun/comeonin.svg?branch=master)](https://travis-ci.com/riverrun/comeonin)
[![Module Version](https://img.shields.io/hexpm/v/comeonin.svg)](https://hex.pm/packages/comeonin)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/comeonin/)
[![Total Download](https://img.shields.io/hexpm/dt/comeonin.svg)](https://hex.pm/packages/comeonin)
[![License](https://img.shields.io/hexpm/l/comeonin.svg)](https://github.com/riverrun/comeonin/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/riverrun/comeonin.svg)](https://github.com/riverrun/comeonin/commits/master)
[![Join the chat at https://gitter.im/comeonin/Lobby](https://badges.gitter.im/comeonin/Lobby.svg)](https://gitter.im/comeonin/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Comeonin is a specification for password hashing libraries.

For information about hashing passwords in your app, see
[Password hashing libraries](#password-hashing-libraries).

## Changes in version 5

In version 5.0 and above, Comeonin now provides two behaviours, Comeonin and
Comeonin.PasswordHash, which password hash libraries then implement.

With these changes, Comeonin is now a dependency of the password hashing
library you choose to use, and in most cases, you will not use it
directly.

See the [UPGRADE_v5 guide](https://github.com/riverrun/comeonin/blob/master/UPGRADE_v5.md)
for information about you can upgrade to version 5.

## Password hashing libraries

The following libraries all implement the Comeonin and Comeonin.PasswordHash
behaviours:

* Argon2 - argon2_elixir
  * [docs](https://hexdocs.pm/argon2_elixir)
  * [source](https://github.com/riverrun/argon2_elixir)
* Bcrypt - bcrypt_elixir
  * [docs](https://hexdocs.pm/bcrypt_elixir)
  * [source](https://github.com/riverrun/bcrypt_elixir)
* Pbkdf2 - pbkdf2_elixir
  * [docs](https://hexdocs.pm/pbkdf2_elixir)
  * [source](https://github.com/riverrun/pbkdf2_elixir)

Argon2 is currently considered to be the strongest password hashing function,
and it is the one we recommend.

Bcrypt and Pbkdf2 are viable alternatives, but they are less resistant than Argon2,
to attacks using GPUs or dedicated hardware.

### Windows users

On Windows, it can be time-consuming and problematic to setup the environment needed
to compile the C code in Argon2 and Bcrypt. For this reason, it is often easier to install
Pbkdf2, which has no C dependencies.

For more information, see
[Choosing a library](https://github.com/riverrun/comeonin/wiki/Choosing-the-password-hashing-library).

## Comeonin wiki

See the [Comeonin wiki](https://github.com/riverrun/comeonin/wiki) for more
information on the following topics:

* [Hashing passwords](https://github.com/riverrun/comeonin/wiki/Hashing-passwords) - a general guide to hashing passwords in your Elixir app
* [Password hashing libraries](https://github.com/riverrun/comeonin/wiki/Choosing-the-password-hashing-library)
* [Requirements](https://github.com/riverrun/comeonin/wiki/Requirements)
* [Deployment](https://github.com/riverrun/comeonin/wiki/Deployment) - including information about using Docker
* [References](https://github.com/riverrun/comeonin/wiki/References)

## Contributing

There are many ways you can contribute to the development of Comeonin, including:

* Reporting issues
* Improving documentation
* Sharing your experiences with others
* [Making a financial contribution](#donations)

## Donations

First of all, I would like to emphasize that this software is offered
free of charge. However, if you find it useful, and you would like to
buy me a cup of coffee, you can do so at [PayPal](https://www.paypal.me/alovedalongthe).

### License

BSD. For full details, please read the LICENSE file.
