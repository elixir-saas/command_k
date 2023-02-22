defmodule CommandKTest do
  use ExUnit.Case
  doctest CommandK

  test "greets the world" do
    assert CommandK.hello() == :world
  end
end
