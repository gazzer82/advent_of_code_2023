defmodule AdventOfCode2023.Day3 do
  defp load do
    File.stream!("lib/resources/day3.txt", [])
    |> Enum.map(&String.replace(&1, "\n", "."))
  end

  def one do
    data = load()
    width = String.length(Enum.at(data, 0))
    body = List.to_string(data)

    Enum.zip(
      Regex.scan(~r/\d+/, body)
      |> List.flatten(),
      Regex.scan(~r/\d+/, body, return: :index)
      |> List.flatten()
    )
    |> Enum.map(&find_ranges(&1, body, width))
    |> Enum.filter(fn {_number, _num_start, string} ->
      Regex.match?(~r/[^.^\d^ ]/, string)
    end)
    |> Enum.reduce(0, fn {number, _, _}, acc ->
      acc + String.to_integer(number)
    end)
  end

  def two do
    data = load()
    # width = String.length(Enum.at(data, 0))
    # body = List.to_string(data)
    cogs = find_cogs(data)
    numbers = get_numbers(data) |> List.flatten()

    Enum.map(cogs, &check_for_cog(&1, numbers))
    |> Enum.sum()
  end

  defp find_cogs(data) do
    Enum.reduce(data, {0, []}, fn line, {row, vals} ->
      l =
        Regex.scan(~r"\*", line, return: :index)
        |> List.flatten()
        |> Enum.map(&elem(&1, 0))
        |> Enum.map(fn index ->
          {row, index}
        end)
        |> List.flatten()
        |> Enum.concat(vals)

      {row + 1, l}
    end)
    |> elem(1)
  end

  defp get_numbers(data) do
    Enum.reduce(data, {0, []}, fn line, {row, vals} ->
      num_capture = ~r"\d+"
      nums = Regex.scan(num_capture, line) |> List.flatten()

      indices =
        Regex.scan(num_capture, line, return: :index)
        |> List.flatten()
        |> Enum.map(&elem(&1, 0))

      z_map =
        Enum.zip_with(nums, indices, fn num, index ->
          l = String.length(num)

          %{
            coord: {row, index},
            length: l,
            number: Integer.parse(num) |> elem(0)
          }
        end)

      {row + 1, [z_map | vals]}
    end)
    |> elem(1)
  end

  defp check_for_cog({row, index} = _symbol, num_items) do
    {adj, prod} =
      Enum.reduce(num_items, {0, 1}, fn %{coord: coord, length: l, number: n} = _number,
                                        {count, product} = totals ->
        if count > 2 do
          totals
        else
          y = elem(coord, 0)
          min_y = (y - 1) |> zero?()
          max_y = y + 1

          x = elem(coord, 1)
          min_x = (x - 1) |> zero?()
          max_x = x + l

          row_check = row >= min_y and row <= max_y
          col_check = index >= min_x and index <= max_x

          case row_check and col_check do
            true -> {count + 1, product * n}
            false -> totals
          end
        end
      end)

    case adj == 2 do
      true -> prod
      false -> 0
    end
  end

  defp zero?(x) do
    case x < 0 do
      true -> 0
      false -> x
    end
  end

  # Is hard left first row, special case

  defp find_ranges(number, body, width) do
    {number, {num_start, num_width}} = number
    {actual_start, actual_end} = get_range(num_start, num_width, width)
    actual = String.slice(body, actual_start, actual_end)
    before_range = get_before(body, actual_start, actual_end, width)
    after_range = get_after(body, actual_start, actual_end, width)
    {number, num_start, "#{before_range} #{actual} #{after_range}"}
  end

  # It's the first row, so we don't have a before

  defp get_before(_body, actual_start, _actual_end, width) when actual_start <= width do
    ""
  end

  defp get_before(body, actual_start, actual_end, width) do
    String.slice(body, actual_start - width, actual_end)
  end

  # It's the last row, so we don't have an after

  defp get_after(body, actual_start, actual_end, width) do
    body_length = String.length(body)

    if actual_start + width > body_length do
      ""
    else
      String.slice(body, actual_start + width, actual_end)
    end
  end

  # Hard left first row

  defp get_range(num_start, num_width, _width) when num_start == 0 do
    {num_start, num_width + 1}
  end

  # Hard left

  defp get_range(num_start, num_width, width) when Kernel.rem(num_start, width) == 0 do
    {num_start, num_width + 1}
  end

  # Hard right

  defp get_range(num_start, num_width, width)
       when Kernel.rem(num_start + num_width, width) == 0 do
    {num_start - 2, num_width + 1}
  end

  # Normal

  defp get_range(num_start, num_width, _width) do
    {num_start - 1, num_width + 2}
  end
end
