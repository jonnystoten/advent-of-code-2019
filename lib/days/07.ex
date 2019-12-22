defmodule AdventOfCode.Day7 do
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
    [0, 1, 2, 3, 4]
    |> permutations()
    |> Enum.map(&thruster_signal(&1, memory))
    |> Enum.sort()
    |> Enum.reverse()
    |> hd()
  end

  def part2(%{memory: memory}) do
    [5, 6, 7, 8, 9]
    |> permutations()
    |> Enum.map(&thruster_signal(&1, memory))
    |> Enum.sort()
    |> Enum.reverse()
    |> hd()
  end

  defmodule IOBridge do
    use GenServer

    def start_link(phase_setting) do
      GenServer.start_link(__MODULE__, [phase_setting])
    end

    def init(buffer) do
      {:ok, %{buffer: buffer, pending: nil}}
    end

    def handle_call(:get, _from, %{buffer: [head | tail]} = state) do
      {:reply, head, %{state | buffer: tail}}
    end

    def handle_call(:get, from, %{buffer: []} = state) do
      {:noreply, %{state | pending: from}}
    end

    def handle_call(:stop, _from, %{buffer: buffer} = state) do
      {:stop, :normal, List.last(buffer), state}
    end

    def handle_cast({:put, new_input}, %{pending: nil, buffer: buffer} = state) do
      {:noreply, %{state | buffer: buffer ++ [new_input]}}
    end

    def handle_cast({:put, new_input}, %{pending: pid} = state) do
      GenServer.reply(pid, new_input)
      {:noreply, %{state | pending: nil}}
    end
  end

  defp thruster_signal(phase_settings, memory) do
    [io_1, io_2, io_3, io_4, io_5] =
      Enum.map(phase_settings, fn phase_setting ->
        {:ok, pid} = IOBridge.start_link(phase_setting)
        pid
      end)

    computers = [
      Computer.new(memory, io_1, io_2),
      Computer.new(memory, io_2, io_3),
      Computer.new(memory, io_3, io_4),
      Computer.new(memory, io_4, io_5),
      Computer.new(memory, io_5, io_1)
    ]

    pids =
      Enum.map(computers, fn computer ->
        spawn(Computer, :execute, [computer])
      end)

    GenServer.cast(io_1, {:put, 0})

    Enum.each(pids, fn pid ->
      ref = Process.monitor(pid)

      receive do
        {:DOWN, ^ref, :process, _, _} ->
          :ok
      end
    end)

    GenServer.call(io_1, :stop)
  end

  defp permutations([]), do: [[]]

  defp permutations(list) do
    for elem <- list, rest <- permutations(list -- [elem]) do
      [elem | rest]
    end
  end
end
