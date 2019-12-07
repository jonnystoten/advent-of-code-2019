defmodule AdventOfCode do
  alias AdventOfCode.Http

  @callback setup(String.t()) :: Map.t()
  @callback part1(Map.t()) :: any
  @callback part2(Map.t()) :: any

  def run(day) do
    text_input = Http.get_input(2019, day)
    mod = String.to_existing_atom("Elixir.AdventOfCode.Day#{day}")
    input = apply(mod, :setup, [text_input])

    part1_answer = apply(mod, :part1, [input])
    part2_answer = apply(mod, :part2, [input])

    IO.puts("""
    Day #{day}:
    Part 1: #{part1_answer}
    Part 2: #{part2_answer}
    """)
  end
end
