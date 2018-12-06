defmodule AlchemistReduction do
  def part_one(input) do
    input
    |> String.codepoints()
    |> reduction()
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
    t =
      input_file
      |> File.read!()
      |> String.trim()
      |> AlchemistReduction.part_one()

    IO.puts(String.length(t))

  # input_file
  # |> File.read!()
  # |> AlchemistReduction.part_two()
  # |> IO.puts()

  _ ->
    IO.puts(:stderr, "expected test or an input file")
    System.halt(1)
end
