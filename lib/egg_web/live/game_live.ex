defmodule EggWeb.GameLive do
  use EggWeb, :live_view

  alias EggWeb.Components.TicTacToe
  alias Phoenix.PubSub

  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center w-full h-full">
      <div class="flex items-center justify-start mb-5">
        <div class="mr-4">
          <%= cond do %>
            <% @game_state.winner == @player_id -> %>
              <div class="text-purple-500 text-xl">YOU WON!</div>
            <% @game_state.winner != nil and @game_state.winner != @player_id -> %>
              <div class="text-purple-500 text-xl">😂 You lost 😂</div>
            <% @can_play? -> %>
              <div class="text-purple-500 text-xl">Your turn</div>
            <% true -> %>
              <div class="text-amber-500 text-xl">Oponnent's turn</div>
          <% end %>
        </div>
        <%= if @game_state.winner != nil do %>
          <.link
            href={~p"/lobby"}
            class="bg-purple-500 hover:bg-purple-700 text-white font-bold py-2 px-4 rounded"
          >
            Find a new match
          </.link>
        <% else %>
          <div></div>
        <% end %>
      </div>
      <TicTacToe.board id="game" game={@game_state} is_player_turn={true} />
    </div>
    """
  end

  def mount(%{"id" => game_id}, %{"player_id" => player_id}, socket) do
    pid = Egg.GamePool.get_game(game_id)
    state = Egg.Game.get_state(pid)

    if connected?(socket) do
      PubSub.subscribe(Egg.PubSub, "game:#{game_id}")
    end

    socket =
      assign(socket, player_id: player_id, game_pid: pid, game_state: state)
      |> set_can_play?(state)

    {:ok, socket}
  end

  def handle_event("click_cell", _, %{assigns: %{can_play?: can_play?}} = socket)
      when not can_play? do
    {:noreply, socket}
  end

  def handle_event("click_cell", %{"row" => row, "column" => column}, socket) do
    Egg.Game.click(socket.assigns.game_pid, {row, column})
    {:noreply, assign(socket, can_play?: false)}
  end

  def handle_info({:update_board, state}, socket) do
    socket = socket |> assign(game_state: state) |> set_can_play?(state)
    {:noreply, socket}
  end

  def set_can_play?(%{assigns: %{player_id: player_id}} = socket, state) do
    assign(socket, can_play?: state.turn == player_id)
  end
end
