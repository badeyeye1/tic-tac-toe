defmodule TicTacToeWeb.GamesLiveTest do
  use TicTacToeWeb.ConnCase

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

    assert view
           |> player_option("X")
           |> render_click() =~ "You are: X"

    refute view |> player_selection_modal() |> has_element?()

    open_selection_modal(view)

    assert view
           |> player_option("O")
           |> render_click() =~ "You are: O"
  end

  test "Computer is assigned alternate player after user select mode", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    open_selection_modal(view)

    assert view
           |> player_option("X")
           |> render_click() =~ "Kyle the computer is: O"
  end

  test "Player cannot switch piece after selection", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    open_selection_modal(view)

    view
    |> player_option("X")
    |> render_click()

    refute view |> select_piece_button() |> has_element?()
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
  end
end
