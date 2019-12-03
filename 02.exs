defmodule Day1 do
  def part1(input) do
    input
    |> restore(12, 2)
    |> execute()
  end

  def part2(input) do
    input
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

input = """
1,0,0,3,1,1,2,3,1,3,4,3,1,5,0,3,2,1,10,19,2,9,19,23,1,9,23,27,2,27,9,31,1,31,5,35,2,35,9,39,1,39,10,43,2,43,13,47,1,47,6,51,2,51,10,55,1,9,55,59,2,6,59,63,1,63,6,67,1,67,10,71,1,71,10,75,2,9,75,79,1,5,79,83,2,9,83,87,1,87,9,91,2,91,13,95,1,95,9,99,1,99,6,103,2,103,6,107,1,107,5,111,1,13,111,115,2,115,6,119,1,119,5,123,1,2,123,127,1,6,127,0,99,2,14,0,0
"""

input =
  input
  |> String.trim()
  |> String.split(",")
  |> Enum.map(&String.to_integer/1)

Day1.part1(input)
|> IO.puts()

Day1.part2(input)
|> IO.puts()
