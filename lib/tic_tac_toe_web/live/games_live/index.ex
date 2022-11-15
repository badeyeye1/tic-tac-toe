defmodule TicTacToeWeb.GamesLive.Index do
  use TicTacToeWeb, :live_view
  @pieces ["X", "O"]

  defmodule Board do
    defstruct [:a1, :b1, :c1, :a2, :b2, :a3, :c2, :b3, :c3]
  end

  @impl true
  def mount(_params, _session, socket) do
    board = Map.from_struct(%Board{})
    {:ok, assign(socket, board: board, select_piece: false, pieces: @pieces, piece: nil)}
  end

  @impl true
  def handle_event("select-piece", _, socket) do
    {:noreply, assign(socket, select_piece: true)}
  end

  def handle_event("piece-selected", %{"piece" => piece}, socket) do
    {:noreply, assign(socket, piece: piece, select_piece: false)}
  end
end
