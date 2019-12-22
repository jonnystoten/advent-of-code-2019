defmodule AdventOfCode.Day11 do
  @behaviour AdventOfCode

  def setup(input) do
    %{}
  end

  def part1(%{}) do
    :not_done
  end

  def part2(%{}) do
    :not_done
  end
end

defmodule AdventOfCode.HullPainter do
  defmodule State do
    defstruct direction: :up
  end

  use GenServer

  def init(_) do
    {:ok, %State{}}
  end

  def handle_info()
end
