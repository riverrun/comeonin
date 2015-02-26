defmodule Comeonin.Config do
  @moduledoc """
  This module provides abstraction layer for configuration.
  Followings are valid configuration items.

  | name               | type    | default |
  | :----------------- | :------ | ------: |
  | bcrypt_log_rounds  | integer | 12      |
  | pbkdf2_rounds      | integer | 60000   |
  """

  def bcrypt_log_rounds do
    Application.get_env(:comeonin, :bcrypt_log_rounds, 12)
  end

  def pbkdf2_rounds do
    Application.get_env(:comeonin, :pbkdf2_rounds, 60_000)
  end
end
