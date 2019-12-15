defmodule Mix.Tasks.Day do
  use Mix.Task

  @shortdoc "Run a specific day"
  def run([day]) do
    if day == "all" do
      AdventOfCode.run_all()
    else
      AdventOfCode.run(day)
    end
  end
end
