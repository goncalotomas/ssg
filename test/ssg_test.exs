defmodule SsgTest do
  use ExUnit.Case
  doctest Ssg

  test "greets the world" do
    assert Ssg.hello() == :world
  end
end
