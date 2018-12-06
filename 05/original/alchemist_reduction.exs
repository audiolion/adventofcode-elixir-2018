defmodule AlchemistReduction do
  def part_one(input) do
    input
    |> String.codepoints()
    |> reduction()
  end

  def part_two(input) do
    units =
      Enum.map(MapSet.new(String.codepoints(String.downcase(input))), fn x ->
        [x, String.upcase(x)]
      end)

    Enum.map(units, fn units ->
      String.replace(input, units, "")
      |> String.codepoints()
      |> reduction()
      |> String.length()
    end)
    |> Enum.min()
  end

  def reduction([ch1 | chs]) do
    {polymer, last_char} =
      Enum.reduce(chs, {[], _prev = ch1}, fn next, {acc, prev} ->
        if prev == nil do
          {acc, next}
        else
          if prev != next && (String.capitalize(prev) == next || prev == String.capitalize(next)) do
            {acc, nil}
          else
            {[prev | acc], next}
          end
        end
      end)

    polymer = String.reverse(Enum.join([last_char | polymer], ""))
    original = Enum.join([ch1 | chs], "")

    case polymer == original do
      true -> polymer
      false -> reduction(String.codepoints(polymer))
    end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day5Test do
      use ExUnit.Case

      IO.puts("dabAcCaCBAcCcaDA")

      test "polymer reduction" do
        assert AlchemistReduction.part_one("dabAcCaCBAcCcaDA") == "dabCBAcaDA"
      end

      test "long polymer reduction" do
        assert AlchemistReduction.part_one(
                 "vVZzWwrEeCcwvoOVsSiCHhDQqdcUuWwsiCctVvTIaAKkSCcIpPYmMgGyfFlLENneEeEeqQVNnpPVvTtHhaQeEHhiIEoOzZaeqQqgaAGdDVSsvjJDdhPpWpLlPwmLlMPzZgGpusSTtQqxXUeEUuMkvVKmLDdnNCpPVaABbOnNobBvhHcaaAAloOIipVvsSRrPiIHmMWIinEFfyBbYYyeiGgjJQqIDdQqNqQSsWwoe"
               ) == "rwVaQEaeqWoe"
      end
    end

  [input_file] ->
    # input_file
    # |> File.read!()
    # |> String.trim()
    # |> AlchemistReduction.part_one()
    # |> String.length()
    # |> IO.puts()

    input_file
    |> File.read!()
    |> String.trim()
    |> AlchemistReduction.part_two()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "expected test or an input file")
    System.halt(1)
end
