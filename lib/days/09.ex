defmodule AdventOfCode.Day9 do
  @behaviour AdventOfCode

  alias AdventOfCode.Intcode
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
    {:ok, input_pid} = Intcode.IO.CannedInput.start_link([1])
    {:ok, output_pid} = Intcode.IO.ConsoleOutput.start_link()

    Computer.new(memory, input_pid, output_pid)
    |> Computer.run_to_completion()
  end

  def part2(%{memory: memory}) do
    {:ok, input_pid} = Intcode.IO.CannedInput.start_link([2])
    {:ok, output_pid} = Intcode.IO.ConsoleOutput.start_link()

    Computer.new(memory, input_pid, output_pid)
    |> Computer.run_to_completion()
  end
end
