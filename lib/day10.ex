defmodule AdventOfCode2023.Day10 do
  defp load do
    File.read!("lib/resources/day10.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
  end

  def get_loop do
    tiles = load()

    grid =
      for {row, y} <- Enum.with_index(tiles),
          {tile, x} <- Enum.with_index(row),
          into: %{},
          do: {{x, y}, tile}

    {start, _} = Enum.find(grid, fn {_, tile} -> tile == "S" end)

    graph =
      for {{x, y}, tile} <- grid, reduce: Graph.new() do
        acc ->
          get_adjacents({x, y}, tile)
          |> Enum.reduce(acc, fn a, acc -> Graph.add_edge(acc, {x, y}, a) end)
      end

    {grid,
     graph
     |> Graph.in_neighbors(start)
     |> Enum.reduce(graph, fn n, g ->
       Graph.add_edge(g, start, n)
     end)
     |> Graph.reachable_neighbors([start])}
  end

  def one do
    {_grid, loop} = get_loop()
    length(loop) |> div(2)
  end

  def two do
    {grid, loop} = get_loop()
    geoloop = %Geo.Polygon{coordinates: [loop]}

    grid
    |> Map.keys()
    |> Stream.reject(&(&1 in loop))
    |> Stream.map(&Topo.contains?(geoloop, &1))
    |> Enum.count(& &1)
  end

  defp n({x, y}) do
    {x, y - 1}
  end

  defp e({x, y}) do
    {x + 1, y}
  end

  defp s({x, y}) do
    {x, y + 1}
  end

  defp w({x, y}) do
    {x - 1, y}
  end

  defp get_adjacents(coords, tile) do
    case tile do
      "." -> []
      "S" -> []
      "|" -> [n(coords), s(coords)]
      "-" -> [w(coords), e(coords)]
      "L" -> [n(coords), e(coords)]
      "J" -> [n(coords), w(coords)]
      "7" -> [w(coords), s(coords)]
      "F" -> [e(coords), s(coords)]
    end
  end
end

# "L" -> :north_east
# "J" -> :north_west
# "7" -> :south_west
# "F" -> :south_east

# | is a vertical pipe connecting north and south.
# - is a horizontal pipe connecting east and west.
# L is a 90-degree bend connecting north and east.
# J is a 90-degree bend connecting north and west.
# 7 is a 90-degree bend connecting south and west.
# F is a 90-degree bend connecting south and east.
# . is ground; there is no pipe in this tile.
# S is the starting position of the animal; there is a pipe on this tile, but your sketch doesn't show what shape the pipe has.
