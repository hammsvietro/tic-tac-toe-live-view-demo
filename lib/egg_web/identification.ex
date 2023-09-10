defmodule EggWeb.Identification do
  import Plug.Conn

  def set_player_id(conn, _) do
    put_session(conn, :player_id, Ecto.UUID.generate())
  end
end
