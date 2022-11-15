defmodule TicTacToeWeb.GamesLiveTest do
  use TicTacToeWeb.ConnCase

  import Phoenix.LiveViewTest

  test "display an empty game board", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/")

    assert has_element?(view, "#game-board")
    assert html |> board_cells() |> length() == 9
  end

  defp board_cells(html) do
    Floki.find(html, "#game-board .board-cell")
  end
end
