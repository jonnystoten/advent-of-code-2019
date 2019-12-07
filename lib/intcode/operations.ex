defmodule AdventOfCode.Intcode.Operations do
  alias AdventOfCode.Intcode.Computer

  def add(computer, params, modes) do
    arithmetic(computer, params, modes, fn a, b -> a + b end)
  end

  def mult(computer, params, modes) do
    arithmetic(computer, params, modes, fn a, b -> a * b end)
  end

  defp arithmetic(
         computer,
         [input1, input2, output],
         [input1_mode, input2_mode, :position],
         fun
       ) do
    a = get(computer, input1, input1_mode)
    b = get(computer, input2, input2_mode)
    result = fun.(a, b)

    computer
    |> Computer.set_memory(output, result)
  end

  defp get(_computer, value, :immediate), do: value
  defp get(computer, value, :position), do: Computer.get_memory(computer, value)

  def input(computer, [address], [:position]) do
    str = IO.gets(computer.input, "Input: ")

    input =
      str
      |> String.trim()
      |> String.to_integer()

    computer
    |> Computer.set_memory(address, input)
  end

  def output(computer, [value_or_address], [mode]) do
    value = get(computer, value_or_address, mode)

    IO.puts(computer.output, value)

    computer
  end

  def jump_if_true(computer, params, modes) do
    jump(computer, params, modes, &(&1 != 0))
  end

  def jump_if_false(computer, params, modes) do
    jump(computer, params, modes, &(&1 == 0))
  end

  defp jump(computer, [param, target], [param_mode, target_mode], fun) do
    value = get(computer, param, param_mode)
    target = get(computer, target, target_mode)

    if fun.(value) do
      %Computer{computer | jumped: true, instruction_counter: target}
    else
      computer
    end
  end

  def less_than(computer, params, modes) do
    compare(computer, params, modes, &(&1 < &2))
  end

  def equals(computer, params, modes) do
    compare(computer, params, modes, &(&1 == &2))
  end

  defp compare(computer, [a, b, output], [a_mode, b_mode, :position], fun) do
    a = get(computer, a, a_mode)
    b = get(computer, b, b_mode)

    result =
      if fun.(a, b) do
        1
      else
        0
      end

    Computer.set_memory(computer, output, result)
  end

  def halt(computer, _, _) do
    %Computer{computer | halted: true}
  end
end
