defmodule Egg.Game do
  use GenServer

  alias Phoenix.PubSub

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  def click(pid, {row, col}) do
    GenServer.cast(pid, {:click, row, col})
  end

  @impl true
  def init(%{game_id: game_id, player_1: player_1, player_2: player_2}) do
    {:ok, init_state(game_id, {player_1, player_2})}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:click, row, col}, state) do
    new_state =
      state |> mark_desired_cell({row, col}) |> maybe_assign_winner({row, col}) |> switch_turns()

    cond do
      new_state.cells == state.cells ->
        {:noreply, state}

      true ->
        broadcast_change(new_state)
        {:noreply, new_state}
    end
  end

  defp init_state(game_id, {player_1, player_2}) do
    players = [player_1, player_2]
    turn = Enum.random(players)
    cells = for _ <- 1..9, do: nil

    %{
      game_id: game_id,
      cross: turn,
      circle: players |> Enum.find(&(&1 != turn)),
      turn: turn,
      cells: cells,
      winner: nil
    }
  end

  defp mark_desired_cell(state, {row, col}) do
    player_symbol = get_player_symbol(state)

    cells =
      state.cells
      |> Enum.chunk_every(3)
      |> Enum.with_index()
      |> Enum.map(fn {cell_row, row_idx} ->
        cell_row
        |> Enum.with_index()
        |> Enum.map(fn {cell, col_idx} ->
          if col_idx == col and row_idx == row and is_nil(cell) do
            player_symbol
          else
            cell
          end
        end)
      end)
      |> List.flatten()

    Map.put(state, :cells, cells)
  end

  defp get_player_symbol(state) do
    cross_player = state.cross
    circle_player = state.circle

    case state.turn do
      ^cross_player -> :cross
      ^circle_player -> :circle
    end
  end

  defp switch_turns(%{circle: circle, cross: cross, turn: turn} = state) do
    case turn do
      ^cross -> %{state | turn: circle}
      ^circle -> %{state | turn: cross}
      nil -> state
    end
  end

  defp broadcast_change(state) do
    PubSub.broadcast(Egg.PubSub, "game:#{state.game_id}", {:update_board, state})
  end

  defp maybe_assign_winner(state, {clicked_row, clicked_col}) do
    cond do
      has_won(state, {clicked_row, clicked_col}) ->
        %{state | winner: state.turn, turn: nil}

      true ->
        state
    end
  end

  defp has_won(state, {clicked_row, clicked_col}) do
    chunked_board = Enum.chunk_every(state.cells, 3)
    player_symbol = get_player_symbol(state)

    {col, row, diag, anti_diag} =
      0..2
      |> Enum.reduce({0, 0, 0, 0}, fn idx, {col, row, diag, anti_diag} ->
        col =
          col +
            bool_to_int(chunked_board |> Enum.at(clicked_row) |> Enum.at(idx) == player_symbol)

        row =
          row +
            bool_to_int(chunked_board |> Enum.at(idx) |> Enum.at(clicked_col) == player_symbol)

        diag =
          diag +
            bool_to_int(chunked_board |> Enum.at(idx) |> Enum.at(idx) == player_symbol)

        anti_diag =
          anti_diag +
            bool_to_int(chunked_board |> Enum.at(idx) |> Enum.at(1 - idx + 1) == player_symbol)

        {col, row, diag, anti_diag}
      end)

    col == 3 or row == 3 or diag == 3 or anti_diag == 3
  end

  defp bool_to_int(false), do: 0
  defp bool_to_int(true), do: 1
end
