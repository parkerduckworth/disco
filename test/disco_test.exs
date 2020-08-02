defmodule DiscoTest do
  use ExUnit.Case
  doctest Disco

  test "greets the world" do
    assert Disco.hello() == :world
  end
end
