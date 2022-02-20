defmodule RelayHeatingPad do
  @behaviour Heater
  alias Circuits.GPIO
  
  @impl Heater
  def turn_on_heater(pin) do
    {:ok, gpio} = GPIO.open(pin, :output)
    GPIO.write(gpio, 1)
  end
    

  @impl Heater
  def turn_off_heater(pin) do
    {:ok, gpio} = GPIO.open(pin, :output)
    GPIO.write(gpio, 0)
  end

  @impl Heater
  def is_heater_on(pin) do
    case GPIO.open(pin, :output) do
      {:ok, gpio} ->
        {:ok, GPIO.read(gpio) == 1}
      {:error, reason} ->
        {:error, reason}
    end
  end
end

