defmodule AdventOfCode.Day8 do
  @behaviour AdventOfCode

  @width 25
  @height 6

  def setup(input) do
    layers =
      input
      |> String.trim()
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
      |> Enum.chunk_every(@width * @height)

    %{layers: layers}
  end

  def part1(%{layers: layers}) do
    {ones, twos} =
      layers
      |> Enum.min_by(fn layer -> Enum.count(layer, &(&1 == 0)) end)
      |> Enum.reduce({0, 0}, fn
        1, {ones, twos} -> {ones + 1, twos}
        2, {ones, twos} -> {ones, twos + 1}
        _, acc -> acc
      end)

    ones * twos
  end

  def part2(%{layers: layers}) do
    0..(@width * @height)
    |> Enum.map(fn index ->
      layers
      |> Enum.map(fn layer -> Enum.at(layer, index) end)
      |> Enum.find(&(&1 != 2))
    end)
    |> render()
  end

  defp render(pixels) do
    for y <- 0..(@height - 1) do
      for x <- 0..(@width - 1) do
        pixels
        |> Enum.at(y * @width + x)
        |> char()
        |> IO.write()
      end

      IO.write("\n")
    end

    :ok
  end

  defp char(0), do: " "
  defp char(1), do: "*"
end
