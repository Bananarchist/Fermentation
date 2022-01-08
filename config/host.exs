import Config

# Add configuration that is only needed when running on the host here.
config :fermentation, Fermentation.Repo,
  database: "./data/fermentation.db"

config :fermentation,
  ecto_repos: [Fermentation.Repo]

