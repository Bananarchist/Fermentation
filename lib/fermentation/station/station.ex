defmodule Fermentation.Station do
  use GenServer
  require Logger
  # import Ecto.Query

  @moduledoc """
  Documentation for Fermentation.
  """

  # prolly: turn this into supe for {heater: Fermentation.Station.Heater, sensor: Fermentation.Station.Sensor}
  # have poll in heater checking sensor
  # have a poll in here for writing data from sensor
  # heater proc state: enabled, temp_range, heater, pin
  # sensor proc state: sensor
  # station state: last_reading, last_read_at
  # station init: heater_pin, heater, sensor, heater_enabled, poll_time, max_temp, min_temp
  # heater init: heater_pin, heater, heater_enabled,temp_range
  # sensor init: sensor


  def default_options do
    %{
      heater_pin: 17,
      heater_enabled: false,
      poll_time: 30_000,
      max_temp: {31.0, :celsius},
      min_temp: {24.0, :celsius},
      sensor: SHT30,
      heater: RelayHeatingPad
    }
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    heater_pin = opts[:heater_pin]
    heater_enabled = opts[:heater_enabled]
    poll_time = opts[:poll_time]
    sensor = opts[:sensor]
    heater = opts[:heater]
    {max_temp, max_temp_unit} = opts[:max_temp]
    {min_temp, min_temp_unit} = opts[:min_temp]
    last_reading = sensor.read()
    last_read_at = System.system_time()

    Logger.info("Initialized with polling time #{poll_time}")


    {:ok,
     %{
       last_reading: last_reading,
       last_read_at: last_read_at,
       poll_time: poll_time,
       temp_range: {min_temp, max_temp},
       heater_enabled: heater_enabled,
       heater_pin: heater_pin,
       sensor: sensor,
       heater: heater
     }}
  end

  @impl true
  def handle_call(:configuration, _from, state) do
    {:reply,
     %{
       heater_enabled: state[:heater_enabled],
       poll_time: state[:poll_time],
       temp_range: state[:temp_range]
     }, state}
  end

  # def handle_cast(:set_max
  # def handle_cast(:set_min
  # def handle_cast(:poll_time
  # migrate to event system

  # query = Ecto.Query.from r in Fermentation.ReadingSHT, where: r.inserted_at > ^(DateTime.add(DateTime.utc_now, -3600, :second)), order_by: [desc: :inserted_at], select: {avg(r.degrees_celsius), count(r.id), avg(r.percent_humidity)}

  @doc """
  Setup RPI3 as a server/brain
    - Direct connect to modem
    - Data stores, etc
    - Provisions nerves software to clients?
  """
end
