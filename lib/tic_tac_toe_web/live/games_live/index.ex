defmodule TicTacToeWeb.GamesLive.Index do
  use TicTacToeWeb, :live_view

  defmodule Board do
    defstruct [:a1, :b1, :c1, :a2, :b2, :a3, :c2, :b3, :c3]
  end

  @impl true
  def mount(_params, _session, socket) do
    board = Map.from_struct(%Board{})
    {:ok, assign(socket, board: board)}
  end
end
