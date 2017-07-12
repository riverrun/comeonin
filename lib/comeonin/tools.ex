defmodule Comeonin.Tools do
  @moduledoc """
  """

  @doc """
  """
  def argon2_check do
    try do
      :erlang.system_info(:dirty_cpu_schedulers_online)
      "You can use Argon2 :)"
    rescue
      _ -> "You cannot use Argon2"
    end
  end

end
