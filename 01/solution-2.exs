{:ok, input} = File.read(Path.expand("./input-2.txt"))
data = String.split(input, "\n", [])

defmodule AOC.Day1 do
  def find_frequency(data) do
    stream = Stream.cycle(data)

    Enum.reduce_while(
      stream,
      %{frequency: 0, frequencies: MapSet.new()},
      fn x,
         %{
           frequency: frequency,
           frequencies: frequencies
         } ->
        {num, _} = Integer.parse(x)
        next_frequency = num + frequency

        case MapSet.member?(frequencies, next_frequency) do
          true ->
            {:halt, next_frequency}

          false ->
            {:cont,
             %{frequency: next_frequency, frequencies: MapSet.put(frequencies, next_frequency)}}
        end
      end
    )
  end
end

result = AOC.Day1.find_frequency(data)
IO.puts(result)
