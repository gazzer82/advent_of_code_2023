defmodule AdventOfCode2023.Day8 do
  defp load do
    [steps | maps] =
      File.stream!("lib/resources/day8.txt", [])
      |> Enum.map(& &1)
      |> Enum.filter(&(&1 != "\n"))
      |> Enum.map(&String.replace(&1, "\n", ""))

    Enum.reduce(
      maps,
      %{
        steps: String.graphemes(steps)
      },
      fn map, acc ->
        [key | [steps]] = String.split(map, "=", trim: true)

        Map.put(
          acc,
          key |> String.trim(),
          steps
          |> String.replace(~r/[\(|\)| ]/, "")
          |> String.split(",")
          |> (&%{"L" => Enum.at(&1, 0), "R" => Enum.at(&1, 1)}).()
        )
      end
    )
  end

  def one do
    load() |> find_end()
  end

  def two do
    map = load()
    starts = find_starts(map)

    Enum.map(starts, &find_end_b(map, 0, &1, 0))
    |> Enum.reduce(0, fn count, acc ->
      if acc == 0 do
        count
      else
        div(count * acc, Integer.gcd(count, acc))
      end
    end)
  end

  defp find_starts(map) do
    Map.delete(map, :steps)
    |> Map.to_list()
    |> Enum.map(fn {key, _steps} ->
      key
    end)
    |> Enum.filter(&String.ends_with?(&1, "A"))
  end

  defp find_end(map, step_index \\ 0, ins_key \\ "AAA", count \\ 0)

  defp find_end(_map, _step_index, ins_key, count) when ins_key == "ZZZ", do: count

  defp find_end(%{steps: steps} = map, step_index, ins_key, count) do
    {next_step_index, step} = get_step(steps, step_index)
    find_end(map, next_step_index, map[ins_key][step], count + 1)
  end

  defp find_end_b(%{steps: steps} = map, step_index, ins_key, count) do
    if String.ends_with?(ins_key, "Z") do
      count
    else
      {next_step_index, step} = get_step(steps, step_index)
      find_end_b(map, next_step_index, map[ins_key][step], count + 1)
    end
  end

  defp get_step(steps, step_index) when step_index == length(steps) - 1 do
    {0, Enum.at(steps, step_index)}
  end

  defp get_step(steps, step_index) do
    {step_index + 1, Enum.at(steps, step_index)}
  end
end
