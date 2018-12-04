defmodule SneakStrategy do
  def strategy_one(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_log(&1))
    |> Enum.sort()
    |> create_guard_sleep_map()
    |> sleepiest_guard()
    |> sleepiest_minute()

    # extract date, sort by date
    # map guard ID key, value of minutes asleep [22, 23, 24, 24, 30, 31]
    # choose guard ID with highest sum of minutes asleep value
    # find most repeated number in list
    # multiple repeated number by guard id
  end

  def parse_log(log) do
    if String.contains?(log, "#") do
      %{"dt" => datetime, "guard_id" => guard_id} =
        Regex.named_captures(~r/\[(?<dt>.*)\].*(?<guard_id>#[\d])/, log)

      {DateTime.from_iso8601(String.replace(datetime, " ", "T") <> "Z"), guard_id, "starts"}
    else
      [_, date, time, type, _] = String.split(log, ["[", "] ", " "])
      {date <> "T" <> time <> "Z", "", type}
    end
  end

  def create_guard_sleep_map(logs) do
    {guard_sleep_map, _} =
      Enum.reduce(logs, {%{}, nil}, fn {datetime, guard_id, type}, {acc, prev_guard_id} ->
        guard_id =
          if guard_id == "" do
            prev_guard_id
          else
            guard_id
          end

        {Map.update(acc, guard_id, [{datetime, type}], &[{datetime, type} | &1]), guard_id}
      end)

    Enum.reduce(Map.keys(guard_sleep_map), %{}, fn guard_id, acc ->
      sorted_sleep =
        Map.get(guard_sleep_map, guard_id)
        |> Enum.sort()

      Map.put(acc, guard_id, sorted_sleep)
    end)
  end

  def sleepiest_guard(guards) do
    IO.inspect(guards)

    guard_sleep_sums =
      Enum.reduce(Map.keys(guards), %{}, fn guard_id, acc ->
        sleep =
          Map.get(guards, guard_id)
          |> sum_sleep()

        IO.inspect({guard_id, sleep})
        Map.put(acc, guard_id, sleep)
      end)

    # {{sleepiest_guard_id, total_sleep}, _} =
    #   Enum.reduce(
    #     guards,
    #     {{"0", 0}, guards},
    #     fn guard_id, {{sleepiest_guard_id, total_sleep}, guards} ->
    #       IO.inspect(guards)
    #       sleep = Enum.sum(Map.get(guards, guard_id))

    #       if sleep > total_sleep do
    #         {{guard_id, sleep}, guards}
    #       else
    #         {{sleepiest_guard_id, total_sleep}, guards}
    #       end
    #     end
    #   )

    # {sleepiest_guard_id, total_sleep, _sleep_times = Map.get(guards, sleepiest_guard_id)}
  end

  def sum_sleep([{datetime, type} | rest], sum \\ 0) do
    {psum, pdatetime, ptype} = sum_sleep(rest, sum)

    case type do
      "falls" ->
        if ptype === "wakes" do
          {sum + psum +
             DateTime.diff(DateTime.from_iso8601(pdatetime), DateTime.from_iso8601(datetime)),
           datetime, type}
        else
          {sum + psum +
             DateTime.diff(
               DateTime.from_iso8601(add_day(datetime) <> "T00:00:00Z"),
               DateTime.from_iso8601(datetime)
             ), datetime, type}
        end

      _ ->
        {sum + psum, datetime, type}
    end
  end

  def add_day(datetime) do
    [year, month, day, _] = String.split(datetime, " ", "-")
    day = Integer.to_string(String.to_integer(day) + 1)
    Enum.join([year, month, day], "-")
  end

  def sum_sleep([{datetime, type} | []], sum) do
    {sum, datetime, type}
  end

  def sleepiest_minute({sleepiest_guard_id, _, sleep_times}) do
    sleep_frequencies =
      Enum.reduce(sleep_times, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)

    "Sleepiest Guard: " <>
      sleepiest_guard_id <> " at minute: " <> Enum.max(Map.values(sleep_frequencies), 0)
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
