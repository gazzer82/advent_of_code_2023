defmodule AdventOfCode2023.Day4 do
  defp load do
    File.stream!("lib/resources/day4.txt", [])
    |> Enum.map(&String.replace(&1, "\n", ""))
  end

  def one do
    load()
    |> Enum.map(&String.split(&1, ":", trim: true))
    |> Enum.map(fn [card | [raw_numbers]] ->
      {winning, numbers} = parse_numbers(raw_numbers)

      matched =
        Enum.filter(numbers, fn number ->
          Enum.member?(winning, number)
        end)

      %{
        card: card,
        winning: winning,
        numbers: numbers,
        matched: matched,
        score: calculate_score(matched)
      }
    end)
    |> Enum.reduce(0, fn %{score: score}, current ->
      current + score
    end)
  end

  def two do
    # cards =
    load()
    |> Enum.map(&String.split(&1, ":", trim: true))
    |> Enum.map(fn [card | [raw_numbers]] ->
      {winning, numbers} = parse_numbers(raw_numbers)

      matched =
        Enum.filter(numbers, fn number ->
          Enum.member?(winning, number)
        end)

      %{
        card: card,
        winning: winning,
        numbers: numbers,
        matched: length(matched),
        qty: 1
      }
    end)
    |> Enum.with_index(fn element, index -> {index, element} end)
    |> Enum.reduce(%{current: 1}, fn {index, card}, acc ->
      Map.put(acc, index + 1, card) |> Map.put(:count, index + 1)
    end)
    |> map_wins()
    |> Map.to_list()
    |> Enum.reduce(0, fn {_, %{qty: qty}}, acc ->
      acc + qty
    end)
  end

  defp map_wins(%{current: current, count: count} = cards) when current > count,
    do: cards |> Map.delete(:count) |> Map.delete(:current)

  defp map_wins(%{current: current, count: _count} = cards) do
    card = cards[current]
    cards = add_cards(cards, current + 1, card.matched, card.qty)
    map_wins(Map.put(cards, :current, current + 1))
  end

  defp add_cards(cards, _target, matched, _qty) when matched == 0, do: cards

  defp add_cards(cards, target, matched, qty) do
    card_to_update = cards[target]
    updated_card = Map.put(card_to_update, :qty, card_to_update.qty + qty)
    updated_cards = Map.put(cards, target, updated_card)
    add_cards(updated_cards, target + 1, matched - 1, qty)
  end

  #   defp map_wins(%{current: current} = cards) do
  #   card = cards[current]
  #   IO.inspect(card)
  #   add_card(cards, current, card.matched)
  # end

  # defp add_card(cards, current, matched) when current <= matched do
  #   current_card = cards[current]
  #   card_to_update = cards[current + 1]
  #   updated_card = Map.put(card_to_update, :qty, current_card.qty + card_to_update.qty)
  #   updated_cards = Map.put(cards, current + 1, updated_card)
  #   add_card(updated_cards, current + 1, matched)
  # end

  # defp add_card(cards, _current, _matched),
  #   do: map_wins(Map.put(cards, :current, cards.current + 1))

  defp parse_numbers(raw_numbers) do
    [winning | [numbers]] = String.split(raw_numbers, "|", trim: true)

    {winning |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1),
     numbers |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)}
  end

  defp calculate_score(matched) when length(matched) == 0 do
    0
  end

  defp calculate_score(matched) when length(matched) == 1 do
    1
  end

  defp calculate_score(matched) do
    Enum.reduce(1..(length(matched) - 1), 1, fn _i, score -> score * 2 end)
  end
end
