defmodule Fermentation.Station.HeaterServer do
  use GenServer
  require Logger

  @poll_time 300_000 

  def default_options do
    %{
      heater_pin: 17,
      heater_enabled: false,
      max_temp: 31.0,
      min_temp: 24.0,
      heater: RelayHeatingPad,
      sensor: nil
    }
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    # if heater not read in last XXXX time, disable, if nil, disable
    Logger.info("Initializing heater in range (#{opts[:min_temp]}, #{opts[:max_temp]})")

    if opts[:heater_enabled] do schedule_poll(@poll_time) end

    {:ok,
     %{
       last_read_at: nil,
       min_temp: opts[:min_temp],
       max_temp: opts[:max_temp],
       heater_enabled: opts[:heater_enabled],
       heater_pin: opts[:heater_pin],
       heater: opts[:heater]
     }}
  end

  defp schedule_poll(poll_time) do
    Process.send_after(self(), :poll, poll_time)
  end

  @impl true
  def handle_info(:poll, state) do
    schedule_poll(@poll_time)
    pin = state[:heater_pin]
    heater = state[:heater]
    {:ok, heater_on} = heater.is_heater_on(pin)
    # should add some error handling i reckon
    temp = GenServer.call(Fermentation.Station.Sensor, :temperature)
    this_time = System.system_time()

    cond do
      not state[:heater_enabled] && heater_on ->
        heater.turn_off_heater(pin)
	# don't log because manually disabled

      temp >= state[:max_temp] && heater_on ->
        heater.turn_off_heater(pin)
        Fermentation.Event.disable_heater()

      temp <= state[:min_temp] && not heater_on ->
        heater.turn_on_heater(pin)
        Fermentation.Event.enable_heater()

      true ->
        nil
    end

    {:noreply, %{state | last_read_at: this_time}}
  end

  @impl true
  def handle_call(:enable, _from, state) do
    unless state[:heater_enabled] do
      schedule_poll(state[:poll_time])
      state[:heater].turn_on_heater(state[:heater_pin])
    end
    {:reply, :ok, %{state | heater_enabled: true}}
  end

  @impl true
  def handle_call(:disable, _from, state) do
    state[:heater].turn_off_heater(state[:heater_pin])
    {:reply, :ok, %{state | heater_enabled: false}}
  end
  

  # interface
  def disable do
    GenServer.call(__MODULE__, :disable)
  end

  def enable do
    GenServer.call(__MODULE__, :enable)
  end

end 
