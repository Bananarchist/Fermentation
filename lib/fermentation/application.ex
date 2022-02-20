defmodule Fermentation.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Fermentation.Supervisor]

    children =
      [
        # Children for all targets
        # Starts a worker by calling: Fermentation.Worker.start_link(arg)
        # {Fermentation.Worker, arg},
        Fermentation.Repo,
        {Task, &Fermentation.Repo.MigrationHelpers.migrate/0}
      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: Fermentation.Worker.start_link(arg)
      # {Fermentation.Worker, arg},
    ]
  end

  def children(_target) do
    [
      # Children for all targets except host
      # Starts a worker by calling: Fermentation.Worker.start_link(arg)
      # {Fermentation.Worker, arg},
      { Fermentation.Station.Sensor, Fermentation.Station.Sensor.default_options() },
      { Fermentation.Station.HeaterServer,
        %{ Fermentation.Station.HeaterServer.default_options() | heater_enabled: true, max_temp: 28.0  }
      },
    ]
  end

  def target() do
    Application.get_env(:fermentation, :target)
  end
end
