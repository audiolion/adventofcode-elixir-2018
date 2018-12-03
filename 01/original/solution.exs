{:ok, input} = File.read(Path.expand("../input.txt"))
data = String.split(input, "\n")

sum =
  Enum.reduce(data, 0, fn x, acc ->
    {num, _} = Integer.parse(x)
    num + acc
  end)

IO.put(sum)
