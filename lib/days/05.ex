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
    StringIO.open("1", [], fn pid ->
      memory
      |> Computer.new(pid)
      |> Computer.execute()
    end)

    :ok
  end

  def part2(%{memory: memory}) do
    StringIO.open("5", [], fn pid ->
      memory
      |> Computer.new(pid)
      |> Computer.execute()
    end)

    :ok
  end
end
