defmodule Comeonin.Config do
  @moduledoc """
  This module provides an abstraction layer for configuration.
  The following are valid configuration items.

  | name               | type    | default |
  | :----------------- | :------ | ------: |
  | crypto_mod         | atom    | :bcrypt |
  | bcrypt_log_rounds  | integer | 12      |
  | pbkdf2_rounds      | integer | 60000   |
  | pass_length        | integer | 12      |
  | pass_min_length    | integer | 8       |

  `crypto_mod` is only needed for some convenience functions in
  the main Comeonin module. In many cases, you will not need this.

  `bcrypt_log_rounds` and `pbkdf2_rounds` can be used to adjust the
  complexity, and time taken, of the password hashing calculation.
  Please read the documentation for the main Comeonin module,
  which explains why the default values are not always the best
  values to use.

  ## Examples

  The simplest way to change the default values would be to add
  the following to the `config.exs` file in your project.

      config :comeonin,
        crypto_mod: :pbkdf2,
        bcrypt_log_rounds: 14,
        pbkdf2_rounds: 100_000,
        pass_length: 16,
        pass_min_length: 12

  If you want to have different values when developing and testing,
  you can create separate files for each environment: `dev.exs`,
  `prod.exs` and `test.exs`, and add the configuration values to
  the respective file.

  For example, in `test.exs` and `dev.exs`:

      use Mix.Config

      config :comeonin,
        bcrypt_log_rounds: 4,
        pbkdf2_rounds: 1_000

  And in `prod.exs`:

      use Mix.Config

      config :comeonin,
        bcrypt_log_rounds: 14,
        pbkdf2_rounds: 100_000

  If you use separate files for the different environments, remember
  to add, or uncomment, the line `import_config "#\{Mix.env\}.exs"`
  to the `config.exs` file.
  """

  @doc """
  This value is only used by the `create_hash` and `create_user` functions
  in the main Comeonin module. You can choose between using bcrypt or
  pbkdf2_sha512 to hash the password.
  """
  def get_crypto_mod do
    case crypto_mod do
      :pbkdf2 -> Comeonin.Pbkdf2
      _ -> Comeonin.Bcrypt
    end
  end
  defp crypto_mod do
    Application.get_env(:comeonin, :crypto_mod, :bcrypt)
  end

  @doc """
  The number of log rounds the bcrypt function uses. The default
  value of 12 means that 2^12 rounds are used.
  """
  def bcrypt_log_rounds do
    Application.get_env(:comeonin, :bcrypt_log_rounds, 12)
  end

  @doc """
  The number of rounds the pbkdf2_sha512 function uses.
  """
  def pbkdf2_rounds do
    Application.get_env(:comeonin, :pbkdf2_rounds, 60_000)
  end

  @doc """
  For use with the `gen_password` function, the default length of
  a password.
  """
  def pass_length do
    Application.get_env(:comeonin, :pass_length, 12)
  end

  @doc """
  For use with the `strong_password?` function, the minimum length of
  a password.
  """
  def pass_min_length do
    Application.get_env(:comeonin, :pass_min_length, 8)
  end

end
