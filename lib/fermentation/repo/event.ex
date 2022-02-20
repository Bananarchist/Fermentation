defmodule Fermentation.Event do
  use Ecto.Schema

  schema "events" do
    field :event_name, Ecto.Enum, values: [:heater_enabled, :heater_disabled]
    timestamps()
  end

  def enable_heater do
    %Fermentation.Event{
      event_name: :heater_enabled
    } 
    |> Fermentation.Repo.insert!()
  end
  def disable_heater do
    %Fermentation.Event{
      event_name: :heater_disabled
    } 
    |> Fermentation.Repo.insert!()
  end

end
