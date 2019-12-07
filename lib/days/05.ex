defmodule AdventOfCode.Day5 do
  @behaviour AdventOfCode

  alias AdventOfCode.Intcode.Computer

  def setup(input) do
    memory =
      input
      |> String.trim()
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    %{memory: memory}
  end

  def part1(%{memory: memory}) do
    memory
    |> Computer.new()
    |> Computer.execute()

    :ok
  end

  def part2(%{memory: memory}) do
    memory
    |> Computer.new()

    :ok
  end
end
