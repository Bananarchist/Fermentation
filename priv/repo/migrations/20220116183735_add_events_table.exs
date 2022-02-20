defmodule Fermentation.Repo.Migrations.AddEventsTable do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :event_name, :string
      timestamps()
    end
  end
end
