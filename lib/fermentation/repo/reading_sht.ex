defmodule Fermentation.ReadingSHT do
  use Ecto.Schema

  schema "readings" do
    field :degrees_celsius, :float
    field :percent_humidity, :float
    timestamps()
  end
end
