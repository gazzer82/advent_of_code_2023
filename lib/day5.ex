defmodule AdventOfCode2023.Day5 do
  defp load do
    File.read!("lib/resources/day5.txt")
    |> String.split("\n\n")
  end

  def one do
    data = load()

    mapping = %{
      seed_soil: Enum.at(data, 1) |> make_mapping(),
      soil_fert: Enum.at(data, 2) |> make_mapping(),
      fert_water: Enum.at(data, 3) |> make_mapping(),
      water_light: Enum.at(data, 4) |> make_mapping(),
      light_temp: Enum.at(data, 5) |> make_mapping(),
      temp_humid: Enum.at(data, 6) |> make_mapping(),
      humid_loc: Enum.at(data, 7) |> make_mapping()
    }

    Enum.at(data, 0)
    |> String.split(":")
    |> Enum.at(1)
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&map_seed(&1, mapping))
    |> Enum.sort(:asc)
    |> Enum.at(0)
  end

  def two do
    data = load()

    mapping = %{
      seed_soil: Enum.at(data, 1) |> make_mapping(),
      soil_fert: Enum.at(data, 2) |> make_mapping(),
      fert_water: Enum.at(data, 3) |> make_mapping(),
      water_light: Enum.at(data, 4) |> make_mapping(),
      light_temp: Enum.at(data, 5) |> make_mapping(),
      temp_humid: Enum.at(data, 6) |> make_mapping(),
      humid_loc: Enum.at(data, 7) |> make_mapping()
    }

    Enum.at(data, 0)
    |> String.split(":")
    |> Enum.at(1)
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(2)
    |> Enum.map(fn [start, lnth] ->
      start..(start + lnth - 1)
    end)
    |> Enum.map(fn range ->
      {first, second} = Range.split(range, Integer.floor_div(Range.size(range), 2))
      [first, second]
    end)
    |> List.flatten()
    |> Task.async_stream(
      fn range ->
        IO.inspect("Processing:")
        IO.inspect(range)

        Enum.reduce(range, {nil, nil}, fn seed, {prev_loc, _} = prev ->
          loc = map_seed(seed, mapping)

          if loc < prev_loc or prev_loc == nil do
            IO.inspect("new lower location: #{loc}")
            {loc, seed}
          else
            prev
          end
        end)
      end,
      timeout: :infinity
    )
    |> Enum.sort()
    |> IO.inspect()
    |> Enum.at(0)
  end

  def map_seed(key, mapping) do
    key
    |> map_range(:seed_soil, mapping)
    |> map_range(:soil_fert, mapping)
    |> map_range(:fert_water, mapping)
    |> map_range(:water_light, mapping)
    |> map_range(:light_temp, mapping)
    |> map_range(:temp_humid, mapping)
    |> map_range(:humid_loc, mapping)
  end

  defp make_mapping(mapping) do
    [_ | [data]] = String.split(mapping, ":")

    String.split(data, "\n", trim: true)
    |> Enum.map(fn src_map ->
      src_list = String.split(src_map)
      src_start = Enum.at(src_list, 1) |> String.to_integer()
      dst_start = Enum.at(src_list, 0) |> String.to_integer()
      range = Enum.at(src_list, 2) |> String.to_integer()

      %{
        src_start: src_start,
        src_end: src_start + range - 1,
        dst_start: dst_start,
        dst_end: dst_start + range - 1,
        range: range,
        offset: dst_start - src_start
      }
    end)
  end

  defp map_range(src, key, mapping) do
    {key, _} =
      Enum.reduce(
        mapping[key],
        {src, false},
        fn seed_map, src ->
          matches?(src, seed_map)
        end
      )

    key
  end

  def matches?({_src, found} = result, _) when found == true, do: result

  def matches?({src, _found}, %{src_start: src_start, src_end: src_end, offset: offset})
      when src >= src_start and src <= src_end do
    {src + offset, true}
  end

  def matches?(result, _map), do: result
end
