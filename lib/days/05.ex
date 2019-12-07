defmodule AdventOfCode.Day5 do
  @behaviour AdventOfCode

  alias AdventOfCode.Intcode.{Computer, IO}

  def setup(input) do
    memory =
      input
      |> String.trim()
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    %{memory: memory}
  end

  def part1(%{memory: memory}) do
    out_pid = spawn_link(IO, :console_output, [])

    computer = Computer.new(memory, out_pid)
    {pid, ref} = spawn_monitor(Computer, :execute, [computer])

    send(pid, {:io, 1})

    receive do
      {:DOWN, ^ref, _, _, _} ->
        :ok
    end
  end

  def part2(%{memory: memory}) do
    out_pid = spawn_link(IO, :console_output, [])

    computer = Computer.new(memory, out_pid)
    {pid, ref} = spawn_monitor(Computer, :execute, [computer])

    send(pid, {:io, 5})

    receive do
      {:DOWN, ^ref, _, _, _} ->
        :ok
    end
  end
end
