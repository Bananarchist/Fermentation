defmodule RelayHeatingPadTest do
  use ExUnit.Case

  test "returns {:ok, true} if heater on" do
    {:ok, gpio0} = Circuits.GPIO.open(0, :output)
    Circuits.GPIO.write(gpio0, 1)
    assert RelayHeatingPad.is_heater_on(1) == {:ok, true}
  end
  test "returns {:ok, false} if heater off" do
    {:ok, gpio0} = Circuits.GPIO.open(0, :output)
    Circuits.GPIO.write(gpio0, 0)
    assert RelayHeatingPad.is_heater_on(1) == {:ok, false}
  end
  test "returns {:error, _atom} if error opening" do
    assert {:error, _atom} = RelayHeatingPad.is_heater_on(900)
  end
end

