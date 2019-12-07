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

  defp thruster_signal(phase_settings, memory) do
    parent = self()

    out_pid = spawn(__MODULE__, :buffer_io, [parent])

    {pids, first_pid} =
      Enum.map_reduce(phase_settings, out_pid, fn phase_setting, out_pid ->
        computer = Computer.new(memory, out_pid)
        pid = spawn_link(Computer, :execute, [computer])

        send(pid, {:io, phase_setting})

        {pid, pid}
      end)

    send(out_pid, {:set_dest_pid, first_pid})
    send(first_pid, {:io, 0})

    Enum.each(pids, fn pid ->
      ref = Process.monitor(pid)

      receive do
        {:DOWN, ^ref, :process, _, _} ->
          :ok
      end
    end)

    send(out_pid, :done)

    receive do
      {:done, value} ->
        value
    end
  end

  def buffer_io(parent) do
    buffer_io(parent, [], nil)
  end

  def buffer_io(parent, values, dest_pid) do
    receive do
      {:io, value} = msg ->
        send(dest_pid, msg)
        buffer_io(parent, [value | values], dest_pid)

      {:set_dest_pid, pid} ->
        buffer_io(parent, values, pid)

      :done ->
        send(parent, {:done, hd(values)})
    end
  end

  defp permutations([]), do: [[]]

  defp permutations(list) do
    for elem <- list, rest <- permutations(list -- [elem]) do
      [elem | rest]
    end
  end
end
