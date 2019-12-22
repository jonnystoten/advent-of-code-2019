defmodule AdventOfCode.Intcode.IO.CannedInput do
  use GenServer

  def start_link(input_buffer) do
    GenServer.start_link(__MODULE__, input_buffer)
  end

  def init(input_buffer) do
    {:ok, input_buffer}
  end

  def handle_call(:get, _from, [head | tail]) do
    {:reply, head, tail}
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end

  def handle_cast({:input, new_input}, input_buffer) do
    {:noreply, input_buffer ++ [new_input]}
  end
end
