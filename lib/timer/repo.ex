defmodule Timer.Repo do
  use Ecto.Repo,
    otp_app: :timer,
    adapter: Ecto.Adapters.SQLite3
end
