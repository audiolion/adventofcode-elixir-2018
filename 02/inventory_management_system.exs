defmodule Aoc.Year2018.Day02.InventoryManagementSystem do
  @moduledoc """
  ## --- Day 2: Inventory Management System ---

  You stop falling through time, catch your breath, and check the screen on the
  device. "Destination reached. Current Year: 1518. Current Location: North Pole
  Utility Closet 83N10." You made it! Now, to find those anomalies.

  Outside the utility closet, you hear footsteps and a voice. "...I'm not sure
  either. But now that so many people have chimneys, maybe he could sneak in that
  way?" Another voice responds, "Actually, we've been working on a new kind of
  *suit* that would let him fit through tight spaces like that. But, I heard that
  a few days ago, they lost the prototype fabric, the design plans, everything!
  Nobody on the team can even seem to remember important details of the project!"

  "Wouldn't they have had enough fabric to fill several boxes in the warehouse?
  They'd be stored together, so the box IDs should be similar. Too bad it would
  take forever to search the warehouse for *two similar box IDs*..." They walk too
  far away to hear any more.

  Late at night, you sneak to the warehouse - who knows what kinds of paradoxes
  you could cause if you were discovered - and use your fancy wrist device to
  quickly scan every box and produce a list of the likely candidates (your puzzle
  input).

  To make sure you didn't miss any, you scan the likely candidate boxes again,
  counting the number that have an ID containing *exactly two of any letter* and
  then separately counting those with *exactly three of any letter*. You can
  multiply those two counts together to get a rudimentary checksum and compare it
  to what your device predicts.

  For example, if you see the following box IDs:

  - `abcdef` contains no letters that appear exactly two or three times.
  - `bababc` contains two `a` and three `b`, so it counts for both.
  - `abbcde` contains two `b`, but no letter appears exactly three times.
  - `abcccd` contains three `c`, but no letter appears exactly two times.
  - `aabcdd` contains two `a` and two `d`, but it only counts once.
  - `abcdee` contains two `e`.
  - `ababab` contains three `a` and three `b`, but it only counts once.
  Of these box IDs, four of them contain a letter which appears exactly twice, and
  three of them contain a letter which appears exactly three times. Multiplying
  these together produces a checksum of `4 * 3 = 12`.

  *What is the checksum* for your list of box IDs?


  """

  @doc """

  """
  def part_1(input) do
    File.stream!(input)
    |> Stream.map(&String.trim/1)
    |> Enum.to_list()
    |> Enum.map(&count_character_occurrences/1)
    |> Enum.map(&count_ids/1)
    |> sum_ids
  end

  def sum_ids(occurences_map_list) do
    {two_sum, three_sum} =
      Enum.reduce(occurences_map_list, {0, 0}, fn {two_count, three_count},
                                                  {two_sum, three_sum} ->
        {two_sum + two_count, three_sum + three_count}
      end)

    two_sum * three_sum
  end

  def count_ids({_, occurrences_list}) do
    Enum.reduce(occurrences_list, {0, 0}, fn occurrence_count, {two_count, three_count} ->
      case occurrence_count do
        2 -> {two_count + 1, three_count}
        3 -> {two_count, three_count + 1}
        _ -> {two_count, three_count}
      end
    end)
  end

  def count_character_occurrences(string) do
    chars = String.graphemes(string)

    {_, occurences} =
      Enum.reduce(chars, {nil, %{}}, fn ch, {_, acc} ->
        Map.get_and_update(acc, ch, fn current_value ->
          case is_integer(current_value) do
            true -> {current_value, current_value + 1}
            false -> {current_value, 1}
          end
        end)
      end)

    filtered_occurrences =
      MapSet.new(Enum.filter(Map.values(occurences), fn x -> x == 2 or x == 3 end))

    {string, filtered_occurrences}
  end

  @doc """

  """
  def part_2(input) do
    File.stream!(input)
    |> Stream.map(&String.trim/1)
    |> Enum.to_list()
    |> smallest_diff
    |> elem(1)
    |> Enum.join("")
  end

  defp smallest_diff(words) do
    Enum.reduce(
      words,
      {_min_diff = :infinity, _result = "", _worda = "", _wordb = ""},
      fn a, {min_diff, result, worda, wordb} ->
        Enum.reduce(
          words,
          {min_diff, result, worda, wordb},
          fn b, {min_diff, result, worda, wordb} ->
            {diff_len, diff, a, b} = diff_words(a, b)

            case diff_len < min_diff and a != b do
              true -> {diff_len, diff, a, b}
              false -> {min_diff, result, worda, wordb}
            end
          end
        )
      end
    )
  end

  def diff_words(a, b) do
    {chars, diff} =
      Enum.reduce(0..(String.length(a) - 1), {[], 0}, fn index, {chars, diff} ->
        a_char = String.at(a, index)
        b_char = String.at(b, index)

        case a_char == b_char do
          true -> {[a_char | chars], diff}
          false -> {chars, diff + 1}
        end
      end)

    {diff, Enum.reverse(chars), a, b}
  end
end

x = Aoc.Year2018.Day02.InventoryManagementSystem.part_1(Path.expand("./input.txt"))
IO.puts(x)

y = Aoc.Year2018.Day02.InventoryManagementSystem.part_2(Path.expand("./input.txt"))
IO.puts(y)
