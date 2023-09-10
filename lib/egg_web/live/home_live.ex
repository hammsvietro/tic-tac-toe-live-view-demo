defmodule EggWeb.HomeLive do
  use EggWeb, :live_view

  # alias EggWeb.Components.TicTacToe

  def render(assigns) do
    ~H"""
    <%!-- 
    <TicTacToe.board id="game" game={@game} is_player_turn={true} />
    --%>
    <div class="flex flex-row justify-between align-center">
      <h1 class="text-4xl">Live matches</h1>
      <.link
        href={~p"/lobby"}
        class="bg-purple-500 hover:bg-purple-700 text-white font-bold py-2 px-4 rounded"
      >
        Find Match
      </.link>
    </div>
    <div>
      ...
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
