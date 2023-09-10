defmodule Egg.Lobby do
  alias Egg.GamePool
  use GenServer

  # Client
  def join(player_id), do: GenServer.call(__MODULE__, {:join, player_id})

  # Server

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, nil}
  end

  @impl true
  def handle_call({:join, player_id}, {from_pid, _}, nil) do
    {:reply, :ok, {player_id, {from_pid, Process.monitor(from_pid)}}}
  end

  @impl true
  def handle_call({:join, player_2_id}, {player_2_pid, _}, {player_1_id, {player_1_pid, ref}}) do
    {:ok, game_id} = GamePool.new_game({player_1_id, player_2_id})
    Process.demonitor(ref)
    send_message_to_player(player_1_pid, game_id)
    send_message_to_player(player_2_pid, game_id)
    {:reply, :ok, nil}
  end

  @impl true
  def handle_info({:DOWN, _, :process, _, _}, player_pid) when is_pid(player_pid) do
    {:noreply, nil}
  end

  defp send_message_to_player(pid, game_id) do
    send(pid, {:game_found, game_id})
  end
end
