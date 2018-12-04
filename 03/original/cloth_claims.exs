defmodule ClothClaims do
  def common_claims(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_claim_id(&1))
    |> make_claims(initialize_fabric(1))
    |> count_common_claims()
  end

  def parse_claim_id(str) do
    [id, _, start, size] = String.split(str, " ")
    [left, top, _] = String.split(start, [",", ":"])
    [width, height] = String.split(size, "x")

    {id, String.to_integer(left), String.to_integer(top), String.to_integer(width),
     String.to_integer(height)}
  end

  def make_claims([_claim = {id, left, top, width, height} | claims], fabric) do
    updated_fabric =
      Enum.reduce(left..(left + width - 1), fabric, fn x, fabric ->
        Enum.reduce(top..(top + height - 1), fabric, fn y, fabric ->
          Map.update(fabric, {x, y}, [id], fn ids -> [id | ids] end)
        end)
      end)

    make_claims(claims, updated_fabric)
  end

  def make_claims([], fabric) do
    fabric
  end

  def count_common_claims(fabric) do
    Enum.count(Map.values(fabric), fn ids -> length(ids) > 1 end)
  end

  def initialize_fabric(size) do
    Enum.reduce(1..size, %{}, fn x, fabric ->
      Enum.reduce(1..size, fabric, fn y, fabric ->
        Map.put(fabric, {x, y}, [])
      end)
    end)
  end

  def find_isolated_claim(fabric) do
    claimset =
      Enum.reduce(Map.values(fabric), MapSet.new(), fn ids, seen ->
        if length(ids) == 1 do
          MapSet.put(seen, List.first(ids))
        else
          Enum.reduce(ids, seen, fn id, acc -> MapSet.delete(acc, id) end)
        end
      end)

    List.first(MapSet.to_list(claimset))
  end

  def isolated_claim(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_claim_id(&1))
    |> make_claims(initialize_fabric(1))
    |> find_isolated_claim()
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
    |> IO.puts()

    input_file
    |> File.read!()
    |> ClothClaims.isolated_claim()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "expected test or an input file")
    System.halt(1)
end
