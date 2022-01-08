defmodule Fermentation.Repo.Migrations.CreateReadings do
  use Ecto.Migration

  def change do
    create table(:readings) do
      add :degrees_celsius, :float
      add :percent_humidity, :float 
      timestamps()
    end 
  end
end
