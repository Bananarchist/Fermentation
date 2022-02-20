defmodule Heater do
  @doc """
  Turn on heater
  """
  @callback turn_on_heater(number) :: :ok | {:error, String.t}

  @doc """
  Turn off heater
  """
  @callback turn_off_heater(number) :: :ok | {:error, String.t}

  @doc """
  Check if heater is on
  """
  @callback is_heater_on(number) :: {:ok, boolean} | {:error, atom()}
end
