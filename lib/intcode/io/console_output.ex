defmodule AdventOfCode.Intcode.IO.ConsoleOutput do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    {:ok, :no_state}
  end

  def handle_cast({:put, value}, state) do
    IO.puts(value)
    {:noreply, state}
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end
end
