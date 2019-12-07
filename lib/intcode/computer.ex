defmodule AdventOfCode.Intcode.Computer do
  alias __MODULE__
  alias AdventOfCode.Intcode.Operations

  require Logger

  defstruct memory: [],
            instruction_counter: 0,
            halted: false,
            jumped: false,
            input: :stdio,
            output: :stdio

  def new(initial_memory \\ [], input \\ :stdio, output \\ :stdio) do
    IO.puts("New computer starting")
    %Computer{memory: initial_memory, input: input, output: output}
  end

  def get_memory(computer, address) do
    Enum.at(computer.memory, address)
  end

  def set_memory(computer, address, value) do
    %Computer{computer | memory: List.replace_at(computer.memory, address, value)}
  end

  defp get_params(computer, param_count) do
    Enum.slice(computer.memory, computer.instruction_counter + 1, param_count)
  end

  def execute(%Computer{halted: true} = computer) do
    computer
  end

  def execute(computer) do
    {opcode, modes} = current_opcode(computer)
    %{fun: fun, params: param_count} = opcode_info(opcode)
    params = get_params(computer, param_count)

    modes =
      params
      |> Enum.with_index()
      |> Enum.map(fn {_, index} ->
        modes
        |> Enum.at(index, 0)
        |> mode()
      end)

    execute(computer, fun, params, modes)
  end

  defp execute(computer, fun, params, modes) do
    Logger.debug("doing a #{fun}, params: #{inspect(params)}, modes: #{inspect(modes)}")

    apply(Operations, fun, [computer, params, modes])
    |> increment_instruction_counter(length(params) + 1)
    |> Computer.execute()
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

  def increment_instruction_counter(%Computer{jumped: true} = computer, _by) do
    %Computer{computer | jumped: false}
  end

  def increment_instruction_counter(computer, by) do
    %Computer{computer | instruction_counter: computer.instruction_counter + by}
  end

  defp opcode_info(1) do
    %{fun: :add, params: 3}
  end

  defp opcode_info(2) do
    %{fun: :mult, params: 3}
  end

  defp opcode_info(3) do
    %{fun: :input, params: 1}
  end

  defp opcode_info(4) do
    %{fun: :output, params: 1}
  end

  defp opcode_info(5) do
    %{fun: :jump_if_true, params: 2}
  end

  defp opcode_info(6) do
    %{fun: :jump_if_false, params: 2}
  end

  defp opcode_info(7) do
    %{fun: :less_than, params: 3}
  end

  defp opcode_info(8) do
    %{fun: :equals, params: 3}
  end

  defp opcode_info(99) do
    %{fun: :halt, params: 0}
  end

  defp mode(0), do: :position
  defp mode(1), do: :immediate
end
