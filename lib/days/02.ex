defmodule AdventOfCode.Day2 do
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
    |> restore(12, 2)
    |> Computer.execute()
    |> Computer.get_memory(0)
  end

  def part2(%{memory: memory}) do
    memory
    |> Computer.new()
    |> brute_force_inputs()
  end

  defp restore(computer, noun, verb) do
    computer
    |> Computer.set_memory(1, noun)
    |> Computer.set_memory(2, verb)
  end

  defp brute_force_inputs(computer) do
    brute_force_inputs(all_inputs(), computer)
  end

  defp brute_force_inputs([{noun, verb} | tail], computer) do
    result =
      computer
      |> restore(noun, verb)
      |> Computer.execute()
      |> Computer.get_memory(0)

    if result == 19_690_720 do
      100 * noun + verb
    else
      brute_force_inputs(tail, computer)
    end
  end

  defp all_inputs do
    for x <- 0..99, y <- 0..99 do
      {x, y}
    end
  end
end
