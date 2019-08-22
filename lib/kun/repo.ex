defmodule Kun.Repo do
  use Ecto.Repo,
    otp_app: :kun,
    adapter: Ecto.Adapters.Postgres
end
