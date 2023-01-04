defmodule TicTacToeWeb.GamesLive.Index do
  use TicTacToeWeb, :live_view

  defmodule Board do
    defstruct [:a1, :b1, :c1, :a2, :b2, :a3, :c2, :b3, :c3]
  end

  @pieces ["X", "O"]

  @impl true
  @spec mount(any, any, any) :: {:ok, any}
  def mount(_params, _session, socket) do
    {:ok, init_state(socket)}
  end

  @impl true
  def handle_event("select-piece", _, socket) do
    {:noreply, assign(socket, select_piece: true)}
  end

  @impl true
  def handle_event("piece-selected", %{"piece" => piece}, socket) do
    ai_piece = Enum.filter(@pieces, fn item -> item != piece end) |> hd()
    {:noreply, assign(socket, piece: piece, ai_piece: ai_piece, select_piece: false)}
  end

  def handle_event("cell-selected", %{"cell" => cell}, socket) do
    %{assigns: %{piece: piece, ai_piece: ai_piece, board: board, moves: moves}} = socket
    key = String.to_existing_atom(cell)
    board = Map.put(board, key, piece)
    moves = moves + 1
    available_cells = available_cells(board)

    cond do
      has_won?(board, piece) ->
        {:noreply,
         socket
         |> put_flash(:info, "You won!")
         |> assign(board: board)
         |> assign(available_cells: available_cells)}

      moves == 9 ->
        {:noreply,
         socket
         |> put_flash(:error, "Game Over")
         |> assign(board: board)
         |> assign(available_cells: available_cells)}

      true ->
        next_move = generate_next_move(board, ai_piece)
        send(self(), {:ai_move, next_move})
        {:noreply, assign(socket, board: board, moves: moves, available_cells: available_cells)}
    end
  end

  def handle_event("reset", _, socket) do
    socket =
      socket
      |> init_state()
      |> clear_flash()

    {:noreply, init_state(socket)}
  end

  @impl true
  def handle_info({:ai_move, cell}, socket) do
    %{assigns: %{ai_piece: ai_piece, board: board, moves: moves}} = socket
    board = Map.put(board, cell, ai_piece)
    moves = moves + 1
    available_cells = available_cells(board)

    cond do
      has_won?(board, ai_piece) ->
        {:noreply,
         socket
         |> put_flash(:error, "You lost!")
         |> assign(board: board)
         |> assign(available_cells: available_cells)}

      moves == 9 ->
        {:noreply,
         socket
         |> put_flash(:error, "Game Over")
         |> assign(board: board)
         |> assign(available_cells: available_cells)}

      true ->
        {:noreply, assign(socket, board: board, moves: moves, available_cells: available_cells)}
    end
  end

  defp init_state(socket) do
    board = Map.from_struct(%Board{})

    assign(socket,
      pieces: @pieces,
      ai_piece: nil,
      piece: nil,
      board: board,
      moves: 0,
      select_piece: false,
      available_cells: available_cells(board)
    )
  end

  defp available_cells(board) do
    Enum.filter(board, fn {_k, v} -> is_nil(v) end)
  end

  defp has_won?(board, piece) do
    winning_moves = [
      {:a1, :a2, :a3},
      {:b1, :b2, :b3},
      {:c1, :c2, :c3},
      {:a1, :b1, :c1},
      {:a2, :b2, :c2},
      {:a3, :b3, :c3},
      {:a1, :b2, :c3},
      {:a3, :b2, :c1}
    ]

    Enum.any?(winning_moves, fn {pos1, pos2, pos3} ->
      Map.get(board, pos1) == piece && Map.get(board, pos2) == piece and
        Map.get(board, pos3) == piece
    end)
  end

  defp possible_winning_moves(board, player, available_cells) do
    hu_player = Enum.filter(@pieces, fn x -> x != player end) |> hd()

    Enum.reduce(available_cells, %{}, fn {k, _x}, acc ->
      new_board = Map.put(board, k, hu_player)
      val = has_won?(new_board, hu_player)
      Map.put(acc, k, val)
    end)
    |> Enum.filter(fn {k, v} ->
      if v == true do
        k
      end
    end)
  end

  defp generate_next_move(board, player) do
    available_cells = available_cells(board)

    case possible_winning_moves(board, player, available_cells) do
      [] ->
        {cell, _} = Enum.random(available_cells)
        cell

      [{next_move, _}] ->
        next_move

      possible_moves ->
        {next_move, _} = hd(possible_moves)
        next_move
    end
  end
end
