defmodule Egg.Repo do
  use Ecto.Repo,
    otp_app: :egg,
    adapter: Ecto.Adapters.Postgres
end
