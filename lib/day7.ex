defmodule AdventOfCode2023.Day6 do
  defp load do
    File.stream!("lib/resources/day7.txt", [])
    |> Enum.map(&String.replace(&1, "\n", ""))
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> Enum.map(fn [cards | [score]] ->
      %{cards: cards |> String.graphemes(), score: score |> String.to_integer()}
    end)
    |> Enum.map(fn hand ->
      Map.put(
        hand,
        :groups,
        Enum.group_by(hand.cards, & &1)
        |> Map.to_list()
        |> Enum.map(fn {_card, qty} ->
          length(qty)
        end)
        |> Enum.sort(:desc)
      )
    end)
  end

  def one do
    load()
    |> Enum.map(&Map.put(&1, :hand_score, find_hand(&1)))
    |> Enum.map(&Map.put(&1, :cards_scored, score_cards(&1.cards)))
    |> Enum.group_by(& &1.hand_score)
    |> Map.to_list()
    |> Enum.map(fn {score, hands} ->
      {score,
       hands
       |> Enum.sort(&(&1.cards_scored <= &2.cards_scored))}
    end)
    |> Enum.flat_map(fn {_score, hand} ->
      hand
    end)
    |> Enum.with_index(&{&2 + 1, &1})
    |> Enum.reduce(0, fn {index, %{score: score}}, acc ->
      acc + index * score
    end)
  end

  def two do
    load()
    |> Enum.map(&Map.put(&1, :hand_score, find_hand_j(&1)))
    |> Enum.map(&Map.put(&1, :cards_scored, score_cards(&1.cards)))
    |> Enum.group_by(& &1.hand_score)
    |> Map.to_list()
    |> Enum.map(fn {score, hands} ->
      {score,
       hands
       |> Enum.sort(&(&1.cards_scored <= &2.cards_scored))}
    end)
    |> Enum.flat_map(fn {_score, hand} ->
      hand
    end)
    |> Enum.with_index(&{&2 + 1, &1})
    |> Enum.reduce(0, fn {index, %{score: score}}, acc ->
      acc + index * score
    end)
  end

  # Five of a kind, where all five cards have the same label: AAAAA 7
  defp find_hand_j(%{groups: [highest_group | _rest]}) when highest_group == 5, do: 7

  # Four of a kind, where four cards have the same label and one card has a different label: AA8AA 6
  defp find_hand_j(%{groups: [highest_group | _rest], cards: cards}) when highest_group == 4 do
    if "J" in cards do
      7
    else
      6
    end
  end

  # Full house, where three cards have the same label, and the remaining two cards share a different label: 23332 5
  defp find_hand_j(%{groups: [highest_group | rest], cards: cards})
       when highest_group == 3 and length(rest) == 1 do
    case how_many_jokers(cards) do
      0 ->
        5

      1 ->
        6

      2 ->
        7

      3 ->
        7
    end
  end

  # Three of a kind, where three cards have the same label, and the remaining two cards are each different from any other card in the hand: TTT98 4
  defp find_hand_j(%{groups: [highest_group | _rest], cards: cards}) when highest_group == 3 do
    case how_many_jokers(cards) do
      0 ->
        4

      1 ->
        6

      2 ->
        7

      3 ->
        6
    end
  end

  # Two pair, where two cards share one label, two other cards share a second label, and the remaining card has a third label: 23432 3
  defp find_hand_j(%{groups: [highest_group | rest], cards: cards})
       when highest_group == 2 and length(rest) == 2 do
    case how_many_jokers(cards) do
      0 ->
        3

      1 ->
        5

      2 ->
        6
    end
  end

  # One pair, where two cards share one label, and the other three cards have a different label from the pair and each other: A23A4 2
  defp find_hand_j(%{groups: [highest_group | _rest], cards: cards})
       when highest_group == 2 do
    case how_many_jokers(cards) do
      0 ->
        2

      1 ->
        4

      2 ->
        4
    end
  end

  # High card, where all cards' labels are distinct: 23456 1
  defp find_hand_j(%{groups: groups, cards: cards})
       when length(groups) == 5 do
    case how_many_jokers(cards) do
      0 ->
        1

      1 ->
        2
    end
  end

  defp how_many_jokers(cards) do
    Enum.filter(cards, &(&1 == "J")) |> length()
  end

  defp find_hand(%{groups: [highest_group | _rest]}) when highest_group == 5, do: 7

  defp find_hand(%{groups: [highest_group | _rest]}) when highest_group == 4, do: 6

  defp find_hand(%{groups: [highest_group | rest]})
       when highest_group == 3 and length(rest) == 1,
       do: 5

  defp find_hand(%{groups: [highest_group | _rest]}) when highest_group == 3, do: 4

  defp find_hand(%{groups: [highest_group | rest]})
       when highest_group == 2 and length(rest) == 2,
       do: 3

  defp find_hand(%{groups: [highest_group | _rest]})
       when highest_group == 2,
       do: 2

  defp find_hand(%{groups: groups})
       when length(groups) == 5,
       do: 1

  def sort_scored_hands([card1 | rest1], [card2 | rest2]) do
    IO.inspect("Scoring #{card1} and #{card2}")

    if card1 == card2 do
      true
      sort_scored_hands(rest1, rest2)
    end

    card1 < card2
  end

  defp score_cards(cards) do
    Enum.map(cards, &score_card/1)
  end

  defp score_card(card) do
    case card do
      "A" -> 13
      "K" -> 12
      "Q" -> 11
      "T" -> 10
      "9" -> 9
      "8" -> 8
      "7" -> 7
      "6" -> 6
      "5" -> 5
      "4" -> 4
      "3" -> 3
      "2" -> 2
      "J" -> 1
      "L" -> 1
    end
  end
end
