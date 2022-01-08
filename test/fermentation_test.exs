defmodule FermentationTest do
  use ExUnit.Case
  doctest Fermentation

  test "greets the world" do
    assert Fermentation.hello() == :world
  end
end
