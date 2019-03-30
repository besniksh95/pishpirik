defmodule Pishpirik.Repo do
  use Ecto.Repo,
    otp_app: :pishpirik,
    adapter: Ecto.Adapters.Postgres
end
