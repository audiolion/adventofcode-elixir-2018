{:ok, input} = File.read(Path.expand("../input-reid.txt"))
data = String.split(input, "\n", [])

defmodule AOC.Day1 do
  def find_frequency(data) do
    stream = Stream.cycle(data)

    Enum.reduce_while(
      stream,
      %{frequency: 0, frequencies: MapSet.new(), loops: 0},
      fn x,
         %{
           frequency: frequency,
           frequencies: frequencies,
           loops: loops
         } ->
        {num, _} = Integer.parse(x)
        next_frequency = num + frequency

        case MapSet.member?(frequencies, next_frequency) do
          true ->
            {:halt, next_frequency, loops}

          false ->
            {:cont,
             %{
               frequency: next_frequency,
               frequencies: MapSet.put(frequencies, next_frequency),
               loops: loops + 1
             }}
        end
      end
    )
  end
end

result = AOC.Day1.find_frequency(data)
IO.puts(result)
