defmodule AdventOfCode2023.Day6 do
  defp load do
    File.stream!("lib/resources/day6.txt", [])
    |> Enum.map(&String.replace(&1, "\n", ""))
    |> Enum.map(fn line ->
      String.split(line, ":", trim: true) |> Enum.at(1) |> String.split(" ", trim: true)
    end)
  end

  def one do
    load()
    |> Enum.zip()
    |> Enum.map(fn {time, distance} ->
      %{
        time: String.to_integer(time),
        distance: String.to_integer(distance)
      }
    end)
    |> Enum.map(&find_valid_wins(&1))
    |> Enum.reduce(0, fn valid_races, acc ->
      if acc == 0 do
        length(valid_races)
      else
        acc * length(valid_races)
      end
    end)
  end

  def two do
    [time, distance] =
      load()
      |> Enum.map(fn row ->
        Enum.join(row)
      end)

    [
      %{
        time: String.to_integer(time),
        distance: String.to_integer(distance)
      }
    ]
    |> Enum.map(&find_valid_wins(&1))
    |> Enum.reduce(0, fn valid_races, acc ->
      if acc == 0 do
        length(valid_races)
      else
        acc * length(valid_races)
      end
    end)
  end

  defp find_valid_wins(%{time: time, distance: distance}) do
    0..time
    |> Stream.filter(&find_valid_win(&1, time, distance))
    |> Enum.to_list()
  end

  defp find_valid_win(held_time, time, distance) do
    speed = held_time
    travel_time = time - held_time
    new_distance = speed * travel_time
    new_distance > distance
  end
end
