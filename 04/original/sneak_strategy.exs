defmodule SneakStrategy do
  def strategy_one(input) do
    {sleepiest_guard_id, sleep_minute, _} =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_log(&1))
      |> Enum.sort()
      |> create_guard_sleep_map()
      |> sleepiest_guard()
      |> sleepiest_minute()

    "Sleepiest Guard: " <> sleepiest_guard_id <> " at minute: " <> Integer.to_string(sleep_minute)
  end

  def parse_log(log) do
    if String.contains?(log, "#") do
      %{"dt" => datetime, "guard_id" => guard_id} =
        Regex.named_captures(~r/\[(?<dt>.*)\].*(?<guard_id>#[\d]+)/, log)

      # {DateTime.from_iso8601(String.replace(datetime, " ", "T") <> "Z"), guard_id, "starts"}
      {datetime, guard_id, "starts"}
    else
      [_, date, time, type, _] = String.split(log, ["[", "] ", " "])
      {date <> " " <> time, "", type}
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

        {Map.update(acc, guard_id, [{datetime, type, []}], &[{datetime, type, []} | &1]),
         guard_id}
      end)

    Enum.reduce(Map.keys(guard_sleep_map), %{}, fn guard_id, acc ->
      sorted_sleep =
        Map.get(guard_sleep_map, guard_id)
        |> Enum.sort()

      Map.put(acc, guard_id, sorted_sleep)
    end)
  end

  def sleepiest_guard(guards) do
    guard_sleep_sums =
      Enum.reduce(Map.keys(guards), %{}, fn guard_id, acc ->
        {sleep, _, _, sleep_mins} =
          Map.get(guards, guard_id)
          |> sum_sleep(0)

        Map.put(acc, guard_id, {sleep, sleep_mins})
      end)

    sleepiest_guard_id =
      Enum.reduce(Map.keys(guard_sleep_sums), nil, fn guard_id, sleepiest_guard_id ->
        {sleep, _} = Map.get(guard_sleep_sums, guard_id)
        {curr_sleepiest, _} = Map.get(guard_sleep_sums, sleepiest_guard_id, {0, 0})

        if sleepiest_guard_id == nil || sleep > curr_sleepiest do
          guard_id
        else
          sleepiest_guard_id
        end
      end)

    {guard_sleep_sums, sleepiest_guard_id}
  end

  def sum_sleep([{datetime, type, sleeps} | []], sum) do
    {sum, datetime, type, sleeps}
  end

  def sum_sleep([{datetime, type, _} | rest], sum) do
    {psum, pdatetime, ptype, psleeps} = sum_sleep(rest, sum)

    [date, time] = String.split(datetime, " ")
    [pdate, ptime] = String.split(pdatetime, " ")

    [_, minute] = String.split(time, ":")
    [_, pminute] = String.split(ptime, ":")

    minute = String.to_integer(minute)
    pminute = String.to_integer(pminute)

    different_day =
      case Date.compare(elem(Date.from_iso8601(date), 1), elem(Date.from_iso8601(pdate), 1)) do
        :eq -> false
        _ -> true
      end

    if type == "falls" do
      if different_day do
        mins_asleep =
          Time.diff(elem(Time.from_iso8601("01:00:00"), 1), elem(Time.from_iso8601(time), 1))

        {sum + psum + mins_asleep, datetime, type, [minute..59 | psleeps]}
      else
        if ptype === "wakes" do
          mins_asleep =
            Time.diff(
              elem(Time.from_iso8601(ptime <> ":00"), 1),
              elem(Time.from_iso8601(time <> ":00"), 1)
            ) / 60

          {sum + psum + mins_asleep, datetime, type, [minute..(pminute - 1) | psleeps]}
        else
          {sum + psum, datetime, type, psleeps}
        end
      end
    else
      {sum + psum, datetime, type, psleeps}
    end
  end

  def sleep_frequencies(sleep_times, guard_id) do
    Enum.reduce(elem(Map.get(sleep_times, guard_id), 1), %{}, fn x, acc ->
      Enum.reduce(x, acc, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
    end)
  end

  def sleepiest_minute({sleep_times, sleepiest_guard_id}) do
    frequencies = sleep_frequencies(sleep_times, sleepiest_guard_id)

    {count, sleep_minute} =
      Enum.reduce(Map.keys(frequencies), {0, -1}, fn x, {acc, min} ->
        count = Map.get(frequencies, x)

        if count > acc do
          {count, x}
        else
          {acc, min}
        end
      end)

    {sleepiest_guard_id, sleep_minute, count}
  end

  def strategy_two(input) do
    {sleep_times, _} =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_log(&1))
      |> Enum.sort()
      |> create_guard_sleep_map()
      |> sleepiest_guard()

    sleep_minute_freqs =
      Enum.map(Map.keys(sleep_times), fn guard_id ->
        sleepiest_minute({sleep_times, guard_id})
      end)

    # IO.inspect(sleep_minute_freqs)

    {id, minute, count} =
      Enum.reduce(sleep_minute_freqs, {nil, nil, 0}, fn {guard_id, minute, count},
                                                        {sleepiest_guard_id, sleepiest_minute,
                                                         sleepiest_count} ->
        if count > sleepiest_count do
          {guard_id, minute, count}
        else
          {sleepiest_guard_id, sleepiest_minute, sleepiest_count}
        end
      end)

    "Guard: " <>
      id <> " Minute: " <> Integer.to_string(minute) <> " Count: " <> Integer.to_string(count)
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day4Test do
      use ExUnit.Case

      import SneakStrategy

      test "extract datetime" do
        {:ok, dt, _} = DateTime.from_iso8601("1518-11-01T00:00:25Z")
        assert SneakStrategy.extract_log("[1518-11-01 00:25] wakes up") == {dt, nil}
      end

      test "extract guard id" do
        {:ok, dt, _} = DateTime.from_iso8601("1518-11-01T00:00:25Z")

        assert SneakStrategy.extract_log("[1518-11-01 00:25] guard #12 shift begins") ==
                 {dt, "#12"}
      end

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

    input_file
    |> File.read!()
    |> SneakStrategy.strategy_two()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "expected test or an input file")
    System.halt(1)
end
