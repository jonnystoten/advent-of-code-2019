defmodule AdventOfCode.Day2 do
  @behaviour AdventOfCode

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
    |> restore(12, 2)
    |> execute()
  end

  def part2(%{memory: memory}) do
    memory
    |> brute_force_inputs()
  end

  defp restore(program, noun, verb) do
    program
    |> List.replace_at(1, noun)
    |> List.replace_at(2, verb)
  end

  defp brute_force_inputs(program) do
    brute_force_inputs(all_inputs(), program)
  end

  defp brute_force_inputs([{noun, verb} | tail], program) do
    result =
      program
      |> restore(noun, verb)
      |> execute()

    if result == 19_690_720 do
      100 * noun + verb
    else
      brute_force_inputs(tail, program)
    end
  end

  defp all_inputs do
    for x <- 0..99, y <- 0..99 do
      {x, y}
    end
  end

  defp execute(program) do
    execute(Enum.at(program, 0), 0, program)
  end

  defp execute(cursor, program) do
    opcode = Enum.at(program, cursor)
    execute(opcode, cursor, program)
  end

  defp execute(99, _cursor, program) do
    Enum.at(program, 0)
  end

  defp execute(opcode, cursor, program) do
    [input1, input2, output] = Enum.slice(program, cursor + 1, 3)
    a = Enum.at(program, input1)
    b = Enum.at(program, input2)
    result = op(opcode, a, b)
    program = List.replace_at(program, output, result)
    execute(cursor + 4, program)
  end

  defp op(1, a, b) do
    a + b
  end

  defp op(2, a, b) do
    a * b
  end
end
