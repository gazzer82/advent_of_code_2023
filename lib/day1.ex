defmodule AdventOfCode2023.Day1 do
  defp load do
    {:ok, data} = File.read("lib/resources/day1.txt")
    data
  end

  def one do
    load()
    |> String.split("\n")
    |> Enum.map(&extract_numbers/1)
    |> Enum.map(&last_and_first/1)
    |> Enum.map(&combine/1)
    |> Enum.reduce(0, &(&1 + &2))
  end

  def two do
    load()
    |> String.split("\n")
    |> Enum.map(&extract_numbers_and_string/1)
    |> Enum.map(&map_number_rows/1)
    |> Enum.map(&extract_numbers/1)
    |> Enum.map(&last_and_first/1)
    |> Enum.map(&combine/1)
    |> Enum.reduce(0, &(&1 + &2))
  end

  defp extract_numbers(coords) do
    String.graphemes(coords)
    |> Enum.filter(&String.match?(&1, ~r/\d+/))
  end

  defp extract_numbers_and_string(coords) do
    Regex.scan(~r/(?=(\d|one|two|three|four|five|six|seven|eight|nine))/, coords)
    |> List.flatten()
  end

  defp last_and_first([first | rest]) when length(rest) > 0 do
    [last | _rest] = Enum.reverse(rest)
    [first, last]
  end

  defp last_and_first([number | _]) do
    [number, number]
  end

  defp combine([first, last]) do
    "#{first}#{last}" |> String.to_integer()
  end

  defp map_number_rows(numbers) do
    Enum.map(numbers, &map_numbers/1) |> Enum.join()
  end

  defp map_numbers(number) do
    case number do
      "one" ->
        "1"

      "two" ->
        "2"

      "three" ->
        "3"

      "four" ->
        "4"

      "five" ->
        "5"

      "six" ->
        "6"

      "seven" ->
        "7"

      "eight" ->
        "8"

      "nine" ->
        "9"

      _ ->
        number
    end
  end
end
