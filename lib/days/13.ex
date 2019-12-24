defmodule AdventOfCode.Day13 do
  @behaviour AdventOfCode

  alias AdventOfCode.Intcode.Computer

  defmodule ArcadeCabinet do
    use GenServer

    def start_link() do
      GenServer.start_link(__MODULE__, [])
    end

    def init(_) do
      {:ok, %{grid: Map.new(), step: :x, location: nil, score: 0, ball_x: 0, paddle_x: 0}}
    end

    def handle_cast({:put, -1}, %{step: :x} = state) do
      {:noreply, %{state | step: :segment_y}}
    end

    def handle_cast({:put, 0}, %{step: :segment_y} = state) do
      {:noreply, %{state | step: :segment_score}}
    end

    def handle_cast({:put, value}, %{step: :segment_score} = state) do
      render_score(value)
      {:noreply, %{state | step: :x, location: nil, score: value}}
    end

    def handle_cast({:put, value}, %{step: :x} = state) do
      {:noreply, %{state | step: :y, location: %{x: value}}}
    end

    def handle_cast({:put, value}, %{step: :y, location: location} = state) do
      {:noreply, %{state | step: :type, location: Map.put(location, :y, value)}}
    end

    def handle_cast({:put, value}, %{step: :type, grid: grid, location: location} = state) do
      tile = tile_type(value)
      grid = Map.put(grid, {location.x, location.y}, tile)
      render(location.x, location.y, tile)
      state = %{state | step: :x, location: nil, grid: grid}

      state =
        case tile do
          :ball ->
            %{state | ball_x: location.x}

          :horizontal_paddle ->
            %{state | paddle_x: location.x}

          _ ->
            state
        end

      {:noreply, state}
    end

    def handle_call(:get, from, state) do
      # slow it down so we can see the game play out
      Process.send_after(self(), {:tick, from}, 1)
      {:noreply, state}
    end

    def handle_info({:tick, pid}, %{ball_x: ball_x, paddle_x: paddle_x} = state) do
      direction =
        cond do
          paddle_x < ball_x -> 1
          paddle_x > ball_x -> -1
          paddle_x == ball_x -> 0
        end

      GenServer.reply(pid, direction)
      {:noreply, state}
    end

    defp render(x, y, tile) do
      IO.ANSI.cursor(y + 2, x + 100)
      |> IO.write()

      tile_symbol(tile)
      |> IO.write()
    end

    defp render_score(score) do
      IO.ANSI.cursor(10, 150)
      |> IO.write()

      IO.write("SCORE: #{score}")
    end

    defp tile_type(0), do: :empty
    defp tile_type(1), do: :wall
    defp tile_type(2), do: :block
    defp tile_type(3), do: :horizontal_paddle
    defp tile_type(4), do: :ball

    defp tile_symbol(:empty), do: " "
    defp tile_symbol(:wall), do: "#"
    defp tile_symbol(:block), do: "+"
    defp tile_symbol(:horizontal_paddle), do: "="
    defp tile_symbol(:ball), do: "*"

    def handle_call(:stop, _from, state) do
      block_count =
        state.grid
        |> Map.values()
        |> Enum.count(&(&1 == :block))

      IO.puts("Blocks: #{block_count}")

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
    {:ok, pid} = ArcadeCabinet.start_link()

    Computer.new(memory, nil, pid)
    |> Computer.run_to_completion()
  end

  def part2(%{memory: memory}) do
    {:ok, pid} = ArcadeCabinet.start_link()

    Computer.new(memory, pid, pid)
    |> Computer.set_memory(0, 2)
    |> Computer.run_to_completion()
  end
end
