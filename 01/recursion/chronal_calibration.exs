defmodule ChronalCalibration do
  def final_frequency(input) do
    input
    |> String.split("\n", trim: true)
    |> sum_lines(_frequency = 0)
  end

  defp sum_lines([line | lines], frequency) do
    new_frequency = String.to_integer(line) + frequency
    sum_lines(lines, new_frequency)
  end

  defp sum_lines([], current_frequency) do
    current_frequency
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day1Test do
      use ExUnit.Case

      import ChronalCalibration

      test "final_frequency" do
        {:ok, io} =
          StringIO.open("""
          +1
          +1
          +1
          """)

        assert final_frequency(IO.stream(io, :line) == 3)
      end
    end

  [input_file] ->
    input_file
    |> File.read!()
    |> ChronalCalibration.final_frequency()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "expected test or an input file")
    System.halt(1)
end
