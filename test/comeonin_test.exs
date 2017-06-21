defmodule ComeoninTest do
  use ExUnit.Case, async: true
  doctest Comeonin.Bcrypt.Base64
  doctest Comeonin.Pbkdf2.Base64

end
