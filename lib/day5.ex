defmodule AdventOfCode2023.Day5 do
  defp load do
    File.read!("lib/resources/day5.txt")
    |> String.split("\n\n")

    # |> Enum.map(&String.replace(&1, "\n", ""))
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

  defp split_range(start, length) do
    chunk = Integer.floor_div(length, 4)
    one = start..(start + chunk - 1)
    two = (start + chunk)..(start + chunk * 2 - 1)
    three = (start + chunk * 2)..(start + chunk * 3 - 1)
    four = (start + chunk * 3)..(start + chunk * 4 - 1 + Integer.mod(length, 4))
    [one, two, three, four]
  end

  def two_old do
    data = load()

    seeds =
      Enum.at(data, 0)
      |> String.split(":")
      |> Enum.at(1)
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.chunk_every(2)
      |> Enum.map(fn [start, range] ->
        %{
          dst_start: start,
          dst_end: start + range - 1,
          range: range,
          offset: 0
        }
      end)

    mapping = %{
      seeds: seeds,
      seed_soil: Enum.at(data, 1) |> make_mapping(),
      soil_fert: Enum.at(data, 2) |> make_mapping(),
      fert_water: Enum.at(data, 3) |> make_mapping(),
      water_light: Enum.at(data, 4) |> make_mapping(),
      light_temp: Enum.at(data, 5) |> make_mapping(),
      temp_humid: Enum.at(data, 6) |> make_mapping(),
      humid_loc: Enum.at(data, 7) |> make_mapping()
    }

    mapping[:humid_loc]
    |> Enum.sort_by(& &1.dst_start)
    |> Enum.find_value(fn %{src_start: src_start, src_end: src_end} ->
      Enum.find_value(src_start..src_end, fn key ->
        find_valid(
          key,
          [:temp_humid, :light_temp, :water_light, :fert_water, :soil_fert, :seed_soil, :seeds],
          mapping
        )
      end)
    end)
  end

  defp find_valid(key, [], _ull_mapping), do: key

  defp find_valid(key, [stage | rest], full_mapping) do
    # IO.inspect(stage)
    # IO.inspect(key)
    source =
      full_mapping[stage] ++
        [
          %{
            dst_start: key,
            dst_end: key,
            offset: 0
          }
        ]

    IO.inspect(source)
    IO.inspect(stage)

    Enum.find_value(
      source,
      fn %{
           dst_start: dst_start,
           dst_end: dst_end,
           offset: offset
         } = map ->
        if key >= dst_start and key <= dst_end do
          if stage == :temp_humid do
            IO.inspect("Temp Humid")
            IO.inspect(key)
          end

          find_valid(key + offset, rest, full_mapping)
        else
          false
        end
      end
    )
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
