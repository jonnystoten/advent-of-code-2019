defmodule AdventOfCode.Day13 do
  @behaviour AdventOfCode

  alias AdventOfCode.Intcode.Computer

  defmodule ArcadeScreen do
    use GenServer

    def start_link() do
      GenServer.start_link(__MODULE__, [])
    end

    def init(_) do
      {:ok, %{grid: Map.new(), step: :x, location: nil}}
    end

    def handle_cast({:put, value}, %{step: :x} = state) do
      {:noreply, %{state | step: :y, location: %{x: value}}}
    end

    def handle_cast({:put, value}, %{step: :y, location: location} = state) do
      {:noreply, %{state | step: :type, location: Map.put(location, :y, value)}}
    end

    def handle_cast({:put, value}, %{step: :type, grid: grid, location: location}) do
      grid = Map.put(grid, {location.x, location.y}, tile_type(value))
      {:noreply, %{step: :x, location: nil, grid: grid}}
    end

    defp tile_type(0), do: :empty
    defp tile_type(1), do: :wall
    defp tile_type(2), do: :block
    defp tile_type(3), do: :horizontal_paddle
    defp tile_type(4), do: :ball

    def handle_call(:stop, _from, state) do
      state.grid
      |> Map.values()
      |> Enum.count(&(&1 == :block))
      |> IO.puts()

      {:stop, :normal, :ok, state}
    end
  end

  def setup(input) do
    memory =
      input
      |> String.trim()
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    %{memory: memory}
  end

  def part1(%{memory: memory}) do
    {:ok, output_pid} = ArcadeScreen.start_link()

    Computer.new(memory, nil, output_pid)
    |> Computer.run_to_completion()
  end

  def part2(%{memory: _memory}) do
  end
end
