defmodule AdventOfCode.Intcode.IO do
  def canned_input(input) do
    receive do
      {:waiting, pid} ->
        send(pid, {:io, input})
    end
  end

  def console_output() do
    receive do
      {:io, message} ->
        IO.puts(message)
        console_output()
    end
  end
end
