defmodule ClothClaims do
  def common_claims(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_claim_id(&1))
    |> make_claims(%{})
  end

  def parse_claim_id(str) do
    [id, _, start, size] = String.split(str, " ")
    [left, top, _] = String.split(start, [",", ":"])
    [width, height] = String.split(size, "x")

    {id, String.to_integer(left), String.to_integer(top), String.to_integer(width),
     String.to_integer(height)}
  end

  def make_claims([_claim = {id, left, top, width, height} | claims], fabric) do
    IO.inspect({id, left, top, width, height})
    IO.inspect(fabric)

    new_fabric =
      Enum.reduce(left..(left + width), fabric, fn x, fabric ->
        fabric =
          if fabric[x] == nil do
            Map.put(fabric, x, %{})
          end

        Enum.reduce(top..(top + height), fabric, fn y, fabric ->
          IO.puts(Integer.to_string(x) <> " " <> Integer.to_string(y))
          IO.inspect(fabric[x])

          new_fabric =
            case fabric[x][y] do
              nil ->
                put_in(fabric[x][y], ".")

              "." ->
                put_in(fabric[x][y], "X")

                # ^id -> put_in(fabric[x][y], id)
                # _ -> put_in(fabric[x][y], "X")
            end

          new_fabric
        end)
      end)

    make_claims(claims, new_fabric)
  end

  def make_claims([], fabric) do
    Enum.reduce(Map.keys(fabric), 0, fn row, acc ->
      overlap =
        Map.values(Map.get(fabric, row))
        |> Enum.filter(fn x -> x == "X" end)
        |> length()

      acc + overlap
    end)
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day2Test do
      use ExUnit.Case

      import ClothClaims

      test "parse_claim_id" do
        assert parse_claim_id("#1 @ 1,3: 4x4") == {"#1", 1, 3, 4, 4}
      end

      test "make_claims recursive base case" do
        assert make_claims([], %{
                 0 => %{
                   0 => ".",
                   1 => ".",
                   2 => ".",
                   3 => ".",
                   4 => ".",
                   5 => ".",
                   6 => ".",
                   7 => "."
                 },
                 1 => %{
                   0 => ".",
                   1 => ".",
                   2 => ".",
                   3 => "2",
                   4 => "2",
                   5 => "2",
                   6 => "2",
                   7 => "."
                 },
                 2 => %{
                   0 => ".",
                   1 => ".",
                   2 => ".",
                   3 => "2",
                   4 => "2",
                   5 => "2",
                   6 => "2",
                   7 => "."
                 },
                 3 => %{
                   0 => ".",
                   1 => "1",
                   2 => "1",
                   3 => "X",
                   4 => "X",
                   5 => "2",
                   6 => "2",
                   7 => "."
                 },
                 4 => %{
                   0 => ".",
                   1 => "1",
                   2 => "1",
                   3 => "X",
                   4 => "X",
                   5 => "2",
                   6 => "2",
                   7 => "."
                 },
                 5 => %{
                   0 => ".",
                   1 => "1",
                   2 => "1",
                   3 => "1",
                   4 => "1",
                   5 => "3",
                   6 => "3",
                   7 => "."
                 },
                 6 => %{
                   0 => ".",
                   1 => "1",
                   2 => "1",
                   3 => "1",
                   4 => "1",
                   5 => "3",
                   6 => "3",
                   7 => "."
                 },
                 7 => %{
                   0 => ".",
                   1 => ".",
                   2 => ".",
                   3 => ".",
                   4 => ".",
                   5 => ".",
                   6 => ".",
                   7 => "."
                 }
               }) == 4
      end
    end

  [input_file] ->
    input_file
    |> File.read!()
    |> ClothClaims.common_claims()
    |> IO.inspect()

  _ ->
    IO.puts(:stderr, "expected test or an input file")
    System.halt(1)
end
