defmodule Mix.Tasks.Day do
  use Mix.Task

  @shortdoc "Run a specific day"
  def run(day) do
    AdventOfCode.run(day)
  end
end
