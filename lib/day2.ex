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
    count = get_count(cube)

    cond do
      String.contains?(cube, "red") ->
        if count > counts.red do
          %{counts | red: count}
        else
          counts
        end

      String.contains?(cube, "green") ->
        if count > counts.green do
          %{counts | green: count}
        else
          counts
        end

      String.contains?(cube, "blue") ->
        if count > counts.blue do
          %{counts | blue: count}
        else
          counts
        end
    end
  end

  defp get_count(cube) do
    [count | _] = Regex.run(~r/\d+/, cube)
    String.to_integer(count)
  end

  defp playable_games(%{red: red, green: green, blue: blue})
       when red <= 12 and green <= 13 and blue <= 14,
       do: true

  defp playable_games(_), do: false
end
