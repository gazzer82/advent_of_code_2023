defmodule AdventOfCode2023.Day2 do
  defp load do
    File.stream!("lib/resources/day2.txt")
  end

  def one do
    load()
    |> Enum.map(&String.split(&1, ":", trim: true))
    |> Enum.map(&split_cubes/1)
    |> Enum.filter(&playable_games/1)
    |> Enum.reduce(0, fn %{index: index}, count -> index + count end)
  end

  def two do
    load()
    |> Enum.map(&String.split(&1, ":", trim: true))
    |> Enum.map(&split_cubes/1)
    |> Enum.reduce(0, fn %{red: r, green: g, blue: b}, count ->
      count + r * g * b
    end)
  end

  defp split_cubes([index | [counts]]) do
    [index | _] = Regex.run(~r/\d+/, index)
    counts = String.split(counts, ~r/(;|,)/)

    Enum.reduce(
      counts,
      %{index: String.to_integer(index), red: 0, green: 0, blue: 0},
      &count_colours/2
    )
  end

  defp count_colours(cube, counts) do
    [count | _] = Regex.run(~r/\d+/, cube)
    count = String.to_integer(count)
    [colour | _] = Regex.run(~r/(red|green|blue)/, cube)
    colour = String.to_atom(colour)

    if count > counts[colour] do
      Map.put(counts, colour, count)
    else
      counts
    end
  end

  defp playable_games(%{red: red, green: green, blue: blue})
       when red <= 12 and green <= 13 and blue <= 14,
       do: true

  defp playable_games(_), do: false
end
