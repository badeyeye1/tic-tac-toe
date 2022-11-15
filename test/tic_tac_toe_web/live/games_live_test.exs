defmodule TicTacToeWeb.GamesLiveTest do
  use TicTacToeWeb.ConnCase

  alias TicTacToeWeb.GamesLive.Index.Board

  import Phoenix.LiveViewTest

  test "display an empty game board", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/")

    assert has_element?(view, "#game-board")
    assert html |> board_cells() |> length() == 9
  end

  test "user can select cross or Naught", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(select_piece_button(view))

    open_selection_modal(view)

    assert view |> player_selection_modal() |> has_element?()

    assert has_element?(player_option(view, "X"))
    assert has_element?(player_option(view, "O"))

    pieces = ["O", "X"]
    random_index = Enum.random(0..1)
    piece = Enum.at(pieces, random_index)

    assert view
           |> player_option(piece)
           |> render_click() =~ "You are: #{piece}"

    refute view |> player_selection_modal() |> has_element?()
  end

  test "Computer is assigned alternate player after user select mode", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> open_selection_modal()
    |> select_piece("X")

    assert render(view) =~ "Kyle the computer is: O"
  end

  test "Player cannot switch piece after selection", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> open_selection_modal()
    |> select_piece("X")

    refute view |> select_piece_button() |> has_element?()
  end

  test "Fill cell with player piece when clicked", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> open_selection_modal()
    |> select_piece("X")

    cell = %Board{} |> Map.from_struct() |> Map.keys() |> Enum.random()

    view
    |> element("#cell-#{cell}")
    |> render_click()

    assert has_element?(view, "#cell-#{cell}", "X")
  end

  defp select_piece_button(view) do
    element(view, "[data-role='piece-selector-btn']")
  end

  defp player_selection_modal(view) do
    element(view, "[data-role='player-option']")
  end

  defp player_option(view, option) do
    element(view, "[data-role='player-option-#{option}']")
  end

  defp board_cells(html) do
    Floki.find(html, "#game-board .board-cell")
  end

  defp open_selection_modal(view) do
    view
    |> select_piece_button()
    |> render_click()

    view
  end

  defp select_piece(view, piece) do
    view
    |> player_option(piece)
    |> render_click()

    view
  end
end
