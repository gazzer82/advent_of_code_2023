defmodule AdventOfCode2023.Day9 do
  defp load do
    File.stream!("lib/resources/day9.txt", [])
    |> Enum.map(
      &(String.replace(&1, "\n", "")
        |> String.split(" ", trim: true)
        |> Enum.map(fn code -> String.to_integer(code) end))
    )
  end

  def one do
    load()
    |> Enum.map(&find_differences([&1]))
    |> Enum.map(&make_prediction/1)
    |> Enum.sum()
  end

  def two do
    load()
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(&find_differences([&1]))
    |> Enum.map(&make_prediction/1)
    |> Enum.sum()
  end

  defp find_differences([last_seq | _rest] = seq) do
    if check_for_zeros(last_seq) do
      seq
    else
      %{prev: _prev, seq: next_seq} =
        Enum.reduce(last_seq, %{prev: nil, seq: []}, fn current,
                                                        %{prev: prev, seq: seq} = result ->
          if prev == nil do
            %{result | prev: current}
          else
            %{prev: current, seq: [current - prev | seq]}
          end
        end)

      find_differences([next_seq |> Enum.reverse() | seq])
    end
  end

  defp make_prediction(history, result \\ 0)

  defp make_prediction([], result), do: result

  defp make_prediction([current_seq | rest], result) do
    next_in_current_seq = Enum.at(current_seq, length(current_seq) - 1)

    next_result = result + next_in_current_seq
    make_prediction(rest, next_result)
  end

  defp check_for_zeros(list) do
    Enum.filter(list, &(&1 != 0)) |> Enum.count() == 0
  end
end
