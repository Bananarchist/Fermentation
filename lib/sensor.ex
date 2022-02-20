defmodule Sensor do
  @doc """
  Reads a {temperature, humidity} from sensor
  """
  @callback read() :: {number, number}
end
