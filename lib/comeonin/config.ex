defmodule Comeonin.Config do
  @moduledoc """
  This module provides an abstraction layer for configuration.
  The following are valid configuration items.

  Please read the documentation for the main `Comeonin` module,
  which explains why the default values are not always the best
  values to use.

  | name               | type    | default |
  | :----------------- | :------ | ------: |
  | bcrypt_log_rounds  | integer | 12      |
  | pbkdf2_rounds      | integer | 60000   |

  ## Examples

  The simplest way to change the default values would be to add
  the following to the `config.exs` file in your project.

      config :comeonin,
        bcrypt_log_rounds: 14,
        pbkdf2_rounds: 100_000

  If you want to have different values when developing and testing,
  you can create separate files for each environment: `dev.exs`,
  `prod.exs` and `test.exs`, and add the configuration values to
  the respective file.

  For example, in `test.exs`:

      config :comeonin,
        bcrypt_log_rounds: 4,
        pbkdf2_rounds: 1_000

  And in `prod.exs`:

      config :comeonin,
        bcrypt_log_rounds: 14,
        pbkdf2_rounds: 100_000
  """

  def bcrypt_log_rounds do
    Application.get_env(:comeonin, :bcrypt_log_rounds, 12)
  end

  def pbkdf2_rounds do
    Application.get_env(:comeonin, :pbkdf2_rounds, 60_000)
  end
end
