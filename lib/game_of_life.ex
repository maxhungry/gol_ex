defmodule GameOfLife do
  defstruct grid: %{}, width: 0, height: 0

  def new(width, height) do
    %GameOfLife{
      grid: %{},
      width: width,
      height: height
    }
  end

  def set_cell(%GameOfLife{} = game, x, y, alive \\ true) do
    if alive do
      %{game | grid: Map.put(game.grid, {x, y}, true)}
    else
      %{game | grid: Map.delete(game.grid, {x, y})}
    end
  end

  def alive?(%GameOfLife{} = game, x, y) do
    Map.get(game.grid, {x, y}, false)
  end

  def count_neighbors(%GameOfLife{} = game, x, y) do
    neighbors = [
      {x - 1, y - 1},
      {x, y - 1},
      {x + 1, y - 1},
      {x - 1, y},
      {x + 1, y},
      {x - 1, y + 1},
      {x, y + 1},
      {x + 1, y + 1}
    ]

    Enum.count(neighbors, fn {nx, ny} -> alive?(game, nx, ny) end)
  end

  def next_generation(%GameOfLife{} = game) do
    new_grid =
      for x <- 0..(game.width - 1),
          y <- 0..(game.height - 1),
          reduce: %{} do
        acc ->
          neighbors = count_neighbors(game, x, y)
          cell_alive = alive?(game, x, y)

          cond do
            cell_alive and neighbors in [2, 3] ->
              Map.put(acc, {x, y}, true)

            not cell_alive and neighbors == 3 ->
              Map.put(acc, {x, y}, true)

            true ->
              acc
          end
      end

    %{game | grid: new_grid}
  end

  def display(%GameOfLife{} = game) do
    IO.write("\e[2J\e[H")

    for y <- 0..(game.height - 1) do
      line =
        for x <- 0..(game.width - 1) do
          if alive?(game, x, y), do: "██", else: "  "
        end
        |> Enum.join()

      IO.puts(line)
    end

    IO.puts("")
  end

  def run(game, generations \\ :infinite, delay \\ 200) do
    display(game)

    case generations do
      :infinite ->
        Process.sleep(delay)
        game |> next_generation() |> run(:infinite, delay)

      n when n > 0 ->
        Process.sleep(delay)
        game |> next_generation() |> run(n - 1, delay)

      _ ->
        game
    end
  end

  def glider(game, start_x \\ 1, start_y \\ 1) do
    game
    |> set_cell(start_x + 1, start_y)
    |> set_cell(start_x + 2, start_y + 1)
    |> set_cell(start_x, start_y + 2)
    |> set_cell(start_x + 1, start_y + 2)
    |> set_cell(start_x + 2, start_y + 2)
  end

  def blinker(game, start_x \\ 1, start_y \\ 1) do
    game
    |> set_cell(start_x, start_y)
    |> set_cell(start_x + 1, start_y)
    |> set_cell(start_x + 2, start_y)
  end

  def block(game, start_x \\ 1, start_y \\ 1) do
    game
    |> set_cell(start_x, start_y)
    |> set_cell(start_x + 1, start_y)
    |> set_cell(start_x, start_y + 1)
    |> set_cell(start_x + 1, start_y + 1)
  end

  def demo do
    GameOfLife.new(40, 20)
    |> glider(5, 5)
    |> blinker(15, 8)
    |> block(25, 10)
    |> run()
  end
end

