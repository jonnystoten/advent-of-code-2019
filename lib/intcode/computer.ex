defmodule AdventOfCode.Intcode.Computer do
  alias __MODULE__

  defstruct memory: [], instruction_counter: 0

  defmodule Operations do
    def add(computer) do
      arithmetic(computer, fn a, b -> a + b end)
    end

    def mult(computer) do
      arithmetic(computer, fn a, b -> a * b end)
    end

    def arithmetic(computer, fun) do
      [input1, input2, output] = Enum.slice(computer.memory, computer.instruction_counter + 1, 3)
      a = Computer.get_memory(computer, input1)
      b = Computer.get_memory(computer, input2)
      result = fun.(a, b)

      computer
      |> Computer.set_memory(output, result)
      |> Computer.increment_instruction_counter(4)
      |> Computer.execute()
    end

    def halt(computer) do
      computer
    end
  end

  def new do
    %Computer{}
  end

  def new(initial_memory) do
    %Computer{memory: initial_memory}
  end

  def get_memory(computer, address) do
    Enum.at(computer.memory, address)
  end

  def set_memory(computer, address, value) do
    %Computer{computer | memory: List.replace_at(computer.memory, address, value)}
  end

  def execute(computer) do
    {opcode, _modes} = current_opcode(computer)
    info = opcode_info(opcode)
    execute(computer, info)
  end

  defp execute(computer, %{fun: fun, size: size}) do
    computer = apply(Operations, fun, [computer])
    increment_instruction_counter(computer, size)
  end

  defp current_opcode(computer) do
    raw = Enum.at(computer.memory, computer.instruction_counter)

    op = rem(raw, 100)
    raw = div(raw, 100)

    modes = parse_modes(raw)

    {op, modes}
  end

  defp parse_modes(raw) do
    parse_modes(raw, [])
  end

  defp parse_modes(0, modes), do: Enum.reverse(modes)

  defp parse_modes(raw, modes) do
    parse_modes(div(raw, 10), [rem(raw, 10) | modes])
  end

  def increment_instruction_counter(computer, by) do
    %Computer{computer | instruction_counter: computer.instruction_counter + by}
  end

  defp opcode_info(1) do
    %{fun: :add, size: 4}
  end

  defp opcode_info(2) do
    %{fun: :mult, size: 4}
  end

  defp opcode_info(99) do
    %{fun: :halt, size: 0}
  end
end
