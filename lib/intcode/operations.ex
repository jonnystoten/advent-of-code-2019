defmodule AdventOfCode.Intcode.Operations do
  alias AdventOfCode.Intcode.Computer

  require Logger

  def add(computer, params, modes) do
    arithmetic(computer, params, modes, fn a, b -> a + b end)
  end

  def mult(computer, params, modes) do
    arithmetic(computer, params, modes, fn a, b -> a * b end)
  end

  defp arithmetic(
         computer,
         [input1, input2, output],
         [input1_mode, input2_mode, output_mode],
         fun
       ) do
    a = Computer.operand(computer, input1, input1_mode)
    b = Computer.operand(computer, input2, input2_mode)
    output = Computer.address(computer, output, output_mode)
    result = fun.(a, b)

    computer
    |> Computer.set_memory(output, result)
  end

  def input(%Computer{input_pid: nil}, _, _) do
    raise "no input connected!"
  end

  def input(computer, [address], [address_mode]) do
    address = Computer.address(computer, address, address_mode)

    value = GenServer.call(computer.input_pid, :get)

    Computer.set_memory(computer, address, value)
  end

  def output(%Computer{output_pid: nil}, _, _) do
    raise "no output connected!"
  end

  def output(computer, [value_or_address], [mode]) do
    value = Computer.operand(computer, value_or_address, mode)

    Logger.debug("sending output #{value} to: #{inspect(computer.output_pid)}")
    GenServer.cast(computer.output_pid, {:put, value})

    computer
  end

  def jump_if_true(computer, params, modes) do
    jump(computer, params, modes, &(&1 != 0))
  end

  def jump_if_false(computer, params, modes) do
    jump(computer, params, modes, &(&1 == 0))
  end

  defp jump(computer, [param, target], [param_mode, target_mode], fun) do
    value = Computer.operand(computer, param, param_mode)
    target = Computer.operand(computer, target, target_mode)

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

  defp compare(computer, [a, b, output], [a_mode, b_mode, output_mode], fun) do
    a = Computer.operand(computer, a, a_mode)
    b = Computer.operand(computer, b, b_mode)
    output = Computer.address(computer, output, output_mode)

    result =
      if fun.(a, b) do
        1
      else
        0
      end

    Computer.set_memory(computer, output, result)
  end

  def relative_base_offset(computer, [offset], [offset_mode]) do
    offset = Computer.operand(computer, offset, offset_mode)

    Map.update!(computer, :relative_base, &(&1 + offset))
  end

  def halt(computer, _, _) do
    %Computer{computer | halted: true}
  end
end
