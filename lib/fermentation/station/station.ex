defmodule Fermentation.Station do
  use GenServer
  alias Circuits.{I2C, GPIO}
  require Logger
  import Ecto.Query

  @moduledoc """
  Documentation for Fermentation.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Fermentation.hello
      :world

  """
  def hello do
    :world
  end

  @i2c_code "i2c-1"

  def default_options do
    %{ 
      heater_pin: 17,
      heater_enabled: false,
      poll_time: 30_000,
      max_temp: {31.0, :celsius},
      min_temp: {24.0, :celsius},
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
    {max_temp, max_temp_unit} = opts[:max_temp]
    {min_temp, min_temp_unit} = opts[:min_temp]
    last_reading = read_sht30()
    last_read_at = System.system_time()
    
    Logger.info("Initialized with polling time #{poll_time}")

    schedule_poll(poll_time)
    {:ok, 
      %{
        last_reading: last_reading,
        last_read_at: last_read_at,
        poll_time: poll_time,
        temp_range: {degrees_from(min_temp, min_temp_unit), degrees_from(max_temp, max_temp_unit)},
        heater_enabled: heater_enabled,
        heater_pin: heater_pin
      }
    }
  end

  # Reading handlers and utilities

  defp relative_humidity_reading_as_percent(relhum) do
    100 * (relhum / (:math.pow(2, 16) - 1))
  end

  defp temp_reading_to_degrees_celsius(temp) do
    -45 + 175 * (temp / (:math.pow(2, 16) - 1))
  end

  def degrees_in(temp, :fahrenheit) do
    temp * 9 / 5 + 32
  end

  def degrees_in(temp, :kelvin) do
    temp + 272.15
  end

  def degrees_in(temp, _unit) do
    temp
  end

  def degrees_from(temp, :fahrenheit) do
    (temp - 32) * 5 / 9
  end

  def degrees_from(temp, :kelvin) do
    temp - 272.15
  end

  def degrees_from(temp, _unit) do
    temp
  end

  defp temp_reading_as_degrees(temp) do
    -45 + 175 * (temp / (:math.pow(2, 16) - 1))
  end

  defp read_sht30() do
    {:ok, ref} = I2C.open(@i2c_code)

    {:ok, <<temp::size(16), _tcrc::size(8), relhum::size(16)>>} =
      I2C.write_read(ref, 0x44, <<0x2C, 0x06>>, 5)

    I2C.close(ref)

    {temp_reading_as_degrees(temp), relative_humidity_reading_as_percent(relhum)}
  end

  defp turn_off_heater(heater_pin) do
    {:ok, gpio} = GPIO.open(heater_pin, :output)
    GPIO.write(gpio, 0)
  end

  defp turn_on_heater(heater_pin) do
    {:ok, gpio} = GPIO.open(heater_pin, :output)
    GPIO.write(gpio, 1)
  end

  defp store_temp_and_humidity({temp, humidity}) do
    %Fermentation.ReadingSHT{
      degrees_celsius: temp,
      percent_humidity: humidity
    }
    |> Fermentation.Repo.insert!()
  end

  # Server administration
  defp schedule_poll(next) do
    Process.send_after(self(), :poll, next)
  end

  @impl true
  def handle_info(:poll, state) do
    {min_temp, max_temp} = state[:temp_range]
    {temp, humidity} = read_sht30()
    this_time = System.system_time()

    cond do
      not state[:heater_enabled] ->
        turn_off_heater(state[:heater_pin])

      temp >= max_temp ->
        turn_off_heater(state[:heater_pin])

      temp <= min_temp ->
        turn_on_heater(state[:heater_pin])
    end

    store_temp_and_humidity({temp, humidity})
    schedule_poll(state[:poll_time])
    {:noreply, %{state | last_reading: {temp, humidity}, last_read_at: this_time}}
  end

  @impl true
  def handle_call(:temperature, _from, state) do
    {temp, _humidity} = state[:last_reading]
    {:reply, temp, state}
  end

  @impl true
  def handle_call(:humidity, _from, state) do
    {_temp, humidity} = state[:last_reading]
    {:reply, humidity, state}
  end

  @impl true
  def handle_call(:enable, _from, state) do
    schedule_poll(state[:poll_time])
    turn_on_heater(state[:heater_pin])
    {:reply, :ok, %{state | heater_enabled: true}}
  end

  @impl true
  def handle_call(:disable, _from, state) do
    schedule_poll(state[:poll_time])
    turn_off_heater(state[:heater_pin])
    {:reply, :ok, %{state | heater_enabled: false}}
  end

  # query = Ecto.Query.from r in Fermentation.ReadingSHT, where: r.inserted_at > ^(DateTime.add(DateTime.utc_now, -3600, :second)), order_by: [desc: :inserted_at], select: {avg(r.degrees_celsius), count(r.id), avg(r.percent_humidity)}


  @doc """
  Setup RPI3 as a server/brain
    - Direct connect to modem
    - Data stores, etc
    - Provisions nerves software to clients?
  """
end
