defmodule EggWeb.Components.TicTacToe do
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  attr :id, :string, required: true
  attr :game, :map, required: true
  attr :is_player_turn, :boolean, required: true

  def board(assigns) do
    ~H"""
    <div class="max-w-fit grid grid-cols-3 gap-4">
      <%= for {cell, idx} <- Enum.with_index(@game.cells) do %>
        <.cell row={div(idx, 3)} column={rem(idx, 3)} symbol={cell} />
      <% end %>
    </div>
    """
  end

  attr :row, :integer, required: true
  attr :column, :integer, required: true
  attr :symbol, :atom, required: true

  defp cell(assigns) do
    ~H"""
    <div
      class="w-20 h-20 border-2 border-white rounded-md flex justify-center select-none"
      phx-click={JS.push("click_cell", value: %{row: @row, column: @column})}
    >
      <span class="text-6xl text-center align-center">
        <%= render_symbol(@symbol) %>
      </span>
    </div>
    """
  end

  defp render_symbol(nil), do: ""
  defp render_symbol(:circle), do: "o"
  defp render_symbol(:cross), do: "x"
end
