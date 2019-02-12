# Comeonin

[![Hex.pm Version](http://img.shields.io/hexpm/v/comeonin.svg)](https://hex.pm/packages/comeonin)
[![Build Status](https://travis-ci.org/riverrun/comeonin.svg?branch=master)](https://travis-ci.org/riverrun/comeonin)
[![Join the chat at https://gitter.im/comeonin/Lobby](https://badges.gitter.im/comeonin/Lobby.svg)](https://gitter.im/comeonin/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Comeonin is a specification for password hashing libraries.

## News

Comeonin has been updated to version 5.

In this version, Comeonin now provides two behaviours, Comeonin and
Comeonin.PasswordHash, which password hash libraries then implement.

See the UPGRADE_v5.md file for information about you can upgrade to
version 5.

## Password hashing algorithms

We recommend you use one of the following password hashing libraries.

* Argon2 - [argon2_elixir](http://hexdocs.pm/argon2_elixir)
* Bcrypt - [bcrypt_elixir](http://hexdocs.pm/bcrypt_elixir)
* Pbkdf2 - [pbkdf2_elixir](http://hexdocs.pm/pbkdf2_elixir)

Argon2 is considered to be the strongest password hashing algorithm,
but Bcrypt and Pbkdf2 are viable alternatives. For more information, see
[Choosing an algorithm](https://github.com/riverrun/comeonin/wiki/Choosing-the-password-hashing-algorithm).

## Comeonin wiki

See the [Comeonin wiki](https://github.com/riverrun/comeonin/wiki) for more
information on the following topics:

* [algorithms](https://github.com/riverrun/comeonin/wiki/Choosing-the-password-hashing-algorithm)
* [requirements](https://github.com/riverrun/comeonin/wiki/Requirements)
* [deployment](https://github.com/riverrun/comeonin/wiki/Deployment)
  * including information about using Docker
* [references](https://github.com/riverrun/comeonin/wiki/References)

## Contributing

There are many ways you can contribute to the development of Comeonin, including:

* reporting issues
* improving documentation
* sharing your experiences with others
* [making a financial contribution](#donations)

## Donations

This software is offered free of charge, but if you find it useful
and you would like to buy me a cup of coffee, you can do so through
[paypal](https://www.paypal.me/alovedalongthe).

### Documentation

http://hexdocs.pm/comeonin

### License

BSD. For full details, please read the LICENSE file.
