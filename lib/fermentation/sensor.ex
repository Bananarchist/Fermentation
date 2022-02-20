defmodule Fermentation.Station.Sensor do
  use GenServer
  require Logger
  import Ecto.Query

  @poll_time 60_000

  def default_options do
    %{
      sensor: SHT30
    }
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: Fermentation.Station.Sensor)
  end

  @impl true
  def init(opts) do
    Logger.info("Initializing sensor")

    schedule_poll(@poll_time)
    {temp, humidity} = opts[:sensor].read()
    store_reading(temp, humidity)

    {:ok,
     %{
       last_read_at: nil,
       sensor: opts[:sensor]
     }}
  end

  defp schedule_poll(poll_time) do
    Process.send_after(self(), :poll, poll_time)
  end

  defp store_reading(temp, humidity) do
    %Fermentation.ReadingSHT{
      degrees_celsius: temp,
      percent_humidity: humidity
    }
    |> Fermentation.Repo.insert!()
  end

  @impl true
  def handle_info(:poll, state) do
    schedule_poll(@poll_time)
    {temp, humidity} = state[:sensor].read()
    this_time = System.system_time()
    store_reading(temp, humidity)

    {:noreply, %{state | last_read_at: this_time}}
  end

  @impl true
  def handle_call(:temperature, _from, state) do
    temp =
      Fermentation.ReadingSHT
      |> last(:inserted_at)
      |> Fermentation.Repo.one()
      |> Map.get(:degrees_celsius)

    {:reply, temp, state}
  end

  # interface
  def temperature do
    GenServer.call(__MODULE__, :temperature)
  end
end
