defmodule AdventOfCode.Intcode.Computer do
  alias __MODULE__
  alias AdventOfCode.Intcode.Operations

  require Logger

  defstruct memory: %{},
            instruction_counter: 0,
            relative_base: 0,
            halted: false,
            jumped: false,
            input_pid: nil,
            output_pid: nil

  def new(initial_memory, input_pid \\ nil, output_pid \\ nil)

  def new(initial_memory, input_pid, output_pid) when is_list(initial_memory) do
    memory =
      initial_memory
      |> Enum.with_index()
      |> Map.new(fn {x, i} -> {i, x} end)

    new(memory, input_pid, output_pid)
  end

  def new(initial_memory, input_pid, output_pid) do
    %Computer{memory: initial_memory, input_pid: input_pid, output_pid: output_pid}
  end

  def run_to_completion(computer) do
    {_pid, ref} = spawn_monitor(Computer, :execute, [computer])

    receive do
      {:DOWN, ^ref, :process, _, :normal} ->
        GenServer.call(computer.input_pid, :stop)

        if computer.output_pid != computer.input_pid do
          GenServer.call(computer.output_pid, :stop)
        end

        :ok

      {:DOWN, ^ref, :process, _, _} ->
        # make sure we wait around for the error to be loggged
        Process.sleep(100)
        :error
    end
  end

  def address(_computer, address, :position), do: address
  def address(computer, address, :relative), do: computer.relative_base + address

  def operand(_computer, value, :immediate), do: value

  def operand(computer, value, mode) do
    Computer.get_memory(computer, address(computer, value, mode))
  end

  def get_memory(computer, address) do
    Map.get(computer.memory, address, 0)
  end

  def set_memory(computer, address, value) do
    %Computer{computer | memory: Map.put(computer.memory, address, value)}
  end

  defp get_params(computer, param_count) do
    get_params(computer, param_count, [])
  end

  defp get_params(_computer, 0, result), do: result

  defp get_params(computer, param_count, results) do
    param = get_memory(computer, computer.instruction_counter + param_count)
    get_params(computer, param_count - 1, [param | results])
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
    raw = get_memory(computer, computer.instruction_counter)

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

  defp opcode_info(9) do
    %{fun: :relative_base_offset, params: 1}
  end

  defp opcode_info(99) do
    %{fun: :halt, params: 0}
  end

  defp mode(0), do: :position
  defp mode(1), do: :immediate
  defp mode(2), do: :relative
end
