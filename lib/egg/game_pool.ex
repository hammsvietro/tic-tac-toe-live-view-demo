defmodule Egg.GamePool do
  def new_game({player_1, player_2}) do
    game_id = Ecto.UUID.generate()
    name = registration_name(game_id)

    case GenServer.start_link(
           Egg.Game,
           %{game_id: game_id, player_1: player_1, player_2: player_2},
           name: name
         ) do
      {:ok, _pid} ->
        {:ok, game_id}

      {:error, _reason} = error ->
        error
    end
  end

  def get_game(game_id) do
    [{pid, _}] = Registry.lookup(__MODULE__, game_id)
    pid
  end

  defp registration_name(key) do
    {:via, Registry, {__MODULE__, key}}
  end
end
