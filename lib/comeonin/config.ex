defmodule Comeonin.Config do
  @moduledoc """
  This module provides an abstraction layer for configuration.
  The following are valid configuration items.

  | name               | type    | default |
  | :----------------- | :------ | ------: |
  | bcrypt_log_rounds  | integer | 12      |
  | pbkdf2_rounds      | integer | 60000   |
  | pass_length        | integer | 12      |
  | pass_min_length    | integer | 8       |

  Please read the documentation for the main `Comeonin` module,
  which explains why the default values for `bcrypt_log_rounds` and
  `pbkdf2_rounds` are not always the best values to use.

  The value `pass_length` is for use with the `gen_password` function
  in the `Comeonin` module and is the default length of the generated
  password. `pass_min_length` is for use with the `valid_password?`
  function and is the minimum allowed length.

  ## Examples

  The simplest way to change the default values would be to add
  the following to the `config.exs` file in your project.

      config :comeonin,
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

  def bcrypt_log_rounds do
    Application.get_env(:comeonin, :bcrypt_log_rounds, 12)
  end

  def pbkdf2_rounds do
    Application.get_env(:comeonin, :pbkdf2_rounds, 60_000)
  end

  def pass_length do
    Application.get_env(:comeonin, :pass_length, 12)
  end

  def pass_min_length do
    Application.get_env(:comeonin, :pass_min_length, 8)
  end
end
