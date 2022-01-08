defmodule Fermentation.Repo do
  use Ecto.Repo, otp_app: :fermentation, adapter: Ecto.Adapters.SQLite3
end
