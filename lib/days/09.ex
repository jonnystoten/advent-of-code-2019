defmodule AdventOfCode.Day9 do
  @behaviour AdventOfCode

  alias AdventOfCode.Intcode
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
    out_pid = spawn_link(Intcode.IO, :console_output, [])

    computer = Computer.new(memory, out_pid)
    {pid, ref} = spawn_monitor(Computer, :execute, [computer])

    send(pid, {:io, 1})

    receive do
      {:DOWN, ^ref, :process, _, :normal} ->
        :ok

      {:DOWN, ^ref, :process, _, _} ->
        # make sure we wait around for the error to be loggged
        Process.sleep(100)
        :error
    end
  end

  def part2(%{memory: memory}) do
    out_pid = spawn_link(Intcode.IO, :console_output, [])

    computer = Computer.new(memory, out_pid)
    {pid, ref} = spawn_monitor(Computer, :execute, [computer])

    send(pid, {:io, 2})

    receive do
      {:DOWN, ^ref, :process, _, :normal} ->
        :ok

      {:DOWN, ^ref, :process, _, _} ->
        # make sure we wait around for the error to be loggged
        Process.sleep(100)
        :error
    end
  end
end
