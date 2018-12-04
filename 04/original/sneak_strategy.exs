defmodule SneakStrategy do
  def strategy_one(input) do
    input
    |> String.split("\n", trim: true)

    # extract date, sort by date
    # map guard ID key, value of minutes asleep [22, 23, 24, 24, 30, 31]
    # choose guard ID with highest sum of minutes asleep value
    # find most repeated number in list
    # multiple repeated number by guard id
  end

  def strategy_two() do
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day4Test do
      use ExUnit.Case

      import SneakStrategy

      test "strategy_one" do
        assert SneakStrategy.strategy_one(
                 Enum.join(
                   [
                     "[1518-11-01 00:25] wakes up\n",
                     "[1518-11-01 00:05] falls asleep\n",
                     "[1518-11-01 23:58] Guard #99 begins shift\n",
                     "[1518-11-03 00:24] falls asleep\n",
                     "[1518-11-01 00:30] falls asleep\n",
                     "[1518-11-01 00:55] wakes up\n",
                     "[1518-11-03 00:05] Guard #10 begins shift\n",
                     "[1518-11-01 00:00] Guard #10 begins shift\n",
                     "[1518-11-02 00:50] wakes up\n",
                     "[1518-11-04 00:02] Guard #99 begins shift\n",
                     "[1518-11-02 00:40] falls asleep\n",
                     "[1518-11-05 00:45] falls asleep\n",
                     "[1518-11-04 00:46] wakes up\n",
                     "[1518-11-04 00:36] falls asleep\n",
                     "[1518-11-05 00:55] wakes up\n",
                     "[1518-11-05 00:03] Guard #99 begins shift\n",
                     "[1518-11-03 00:29] wakes up\n"
                   ],
                   ""
                 )
               ) == 240
      end
    end

  [input_file] ->
    input_file
    |> File.read!()
    |> SneakStrategy.strategy_one()
    |> IO.puts()

  # input_file
  # |> File.read!()
  # |> SneakStrategy.strategy_two()
  # |> IO.puts()

  _ ->
    IO.puts(:stderr, "expected test or an input file")
    System.halt(1)
end
