defmodule AdventOfCode do
  alias AdventOfCode.Http

  @callback setup(String.t()) :: Map.t()
  @callback part1(Map.t()) :: any
  @callback part2(Map.t()) :: any

  def run(day) do
    text_input = Http.get_input(2019, day)
    mod = String.to_existing_atom("Elixir.AdventOfCode.Day#{day}")
    input = apply(mod, :setup, [text_input])

    IO.puts("Day #{day}:")
    IO.puts("Part 1:")
    IO.puts(apply(mod, :part1, [input]))
    IO.puts("Part 2:")
    IO.puts(apply(mod, :part2, [input]))
    IO.puts("==================")
  end

  def run_all do
    for day <- 1..25 do
      run(day)
    end
  end
end
