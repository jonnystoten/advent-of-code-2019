defmodule AdventOfCode.Day11 do
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
    {:ok, pid} = AdventOfCode.HullPainter.start_link(:black)

    Computer.new(memory, pid, pid)
    |> Computer.run_to_completion()
  end

  def part2(%{memory: memory}) do
    {:ok, pid} = AdventOfCode.HullPainter.start_link(:white)

    Computer.new(memory, pid, pid)
    |> Computer.run_to_completion()
  end
end

defmodule AdventOfCode.HullPainter do
  defmodule State do
    defstruct position: {0, 0},
              direction: :up,
              grid: Map.new(),
              painted_spaces: MapSet.new(),
              step: :paint
  end

  use GenServer

  def start_link(initial_space_color) do
    GenServer.start_link(__MODULE__, initial_space_color)
  end

  def init(initial_space_color) do
    grid =
      Map.new()
      |> Map.put({0, 0}, initial_space_color)

    {:ok, %State{grid: grid}}
  end

  def handle_call(:get, _from, %State{position: position, grid: grid} = state) do
    result =
      grid
      |> Map.get(position, :black)
      |> color_to_int()

    {:reply, result, state}
  end

  def handle_call(:stop, _from, state) do
    IO.puts(MapSet.size(state.painted_spaces))

    render(state.grid)

    {:stop, :normal, state, state}
  end

  def handle_cast({:put, value}, %State{step: :paint} = state) do
    {:noreply,
     %State{
       state
       | step: :move,
         grid: Map.put(state.grid, state.position, color(value)),
         painted_spaces: MapSet.put(state.painted_spaces, state.position)
     }}
  end

  def handle_cast({:put, value}, %State{step: :move} = state) do
    direction = new_direction(value, state.direction)

    {:noreply,
     %State{
       state
       | step: :paint,
         direction: direction,
         position: new_position(state.position, direction)
     }}
  end

  defp render(grid) do
    {min_x, max_x} =
      grid
      |> Enum.map(fn {{x, _y}, _} -> x end)
      |> Enum.min_max()

    {min_y, max_y} =
      grid
      |> Enum.map(fn {{_x, y}, _} -> y end)
      |> Enum.min_max()

    for y <- max_y..min_y do
      for x <- min_x..max_x do
        grid
        |> Map.get({x, y}, :black)
        |> char()
        |> IO.write()
      end

      IO.write("\n")
    end
  end

  defp color(0), do: :black
  defp color(1), do: :white

  defp color_to_int(:black), do: 0
  defp color_to_int(:white), do: 1

  defp char(:black), do: " "
  defp char(:white), do: "*"

  defp new_direction(0, :up), do: :left
  defp new_direction(0, :left), do: :down
  defp new_direction(0, :down), do: :right
  defp new_direction(0, :right), do: :up

  defp new_direction(1, :up), do: :right
  defp new_direction(1, :right), do: :down
  defp new_direction(1, :down), do: :left
  defp new_direction(1, :left), do: :up

  defp new_position({x, y}, :up), do: {x, y + 1}
  defp new_position({x, y}, :right), do: {x + 1, y}
  defp new_position({x, y}, :down), do: {x, y - 1}
  defp new_position({x, y}, :left), do: {x - 1, y}
end
