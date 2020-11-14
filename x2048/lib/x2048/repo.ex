defmodule X2048.Repo do
  use Ecto.Repo,
    otp_app: :x2048,
    adapter: Ecto.Adapters.Postgres
end
