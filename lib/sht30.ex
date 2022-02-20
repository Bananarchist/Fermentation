defmodule SHT30 do
  @behaviour Sensor
  alias Circuits.I2C

  @i2c_code "i2c-1"

  defp relative_humidity_reading_as_percent(relhum) do
    100 * (relhum / (:math.pow(2, 16) - 1))
  end

  defp temp_reading_as_degrees_celsius(temp) do
    -45 + 175 * (temp / (:math.pow(2, 16) - 1))
  end

  @impl Sensor
  def read() do
    {:ok, ref} = I2C.open(@i2c_code)

    {:ok, <<temp::size(16), _tcrc::size(8), relhum::size(16)>>} =
      I2C.write_read(ref, 0x44, <<0x2C, 0x06>>, 5)

    I2C.close(ref)

    {temp_reading_as_degrees_celsius(temp), relative_humidity_reading_as_percent(relhum)}
  end
end
