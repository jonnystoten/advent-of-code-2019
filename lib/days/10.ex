defmodule AdventOfCode.Day10 do
  @behaviour AdventOfCode

  def setup(input) do
    lines =
      input
      |> String.trim()
      |> String.split()

    asteroids =
      lines
      |> Enum.with_index()
      |> Enum.reduce([], fn {line, y}, state ->
        parse_line(line, y, state)
      end)
      |> Enum.reverse()

    %{asteroids: asteroids}
  end

  defp parse_line(line, y, state) do
    line
    |> String.split("", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(state, fn {char, x}, state ->
      parse_char(char, x, y, state)
    end)
  end

  defp parse_char(".", _, _, state), do: state

  defp parse_char("#", x, y, state) do
    [{x, y} | state]
  end

  def part1(%{asteroids: asteroids}) do
    asteroids
    |> Enum.map(fn asteroid ->
      other_asteroids = Enum.reject(asteroids, &(&1 == asteroid))
      visible_asteroids(asteroid, other_asteroids)
    end)
    |> Enum.max()
  end

  defp visible_asteroids({x, y}, other_asteroids) do
    other_asteroids
    |> Enum.map(fn {other_x, other_y} -> {other_x - x, other_y - y} end)
    |> Enum.group_by(&quadrant/1)
    |> Enum.map(fn {_, group} ->
      group
      |> Enum.group_by(&fraction/1)
      |> Enum.count()
    end)
    |> Enum.sum()
  end

  defp fraction({_, 0}), do: {1, 0}

  defp fraction({x, y}) do
    Float.ratio(x / y)
  end

  defp quadrant({x, y}) do
    cond do
      (sign(x) == 0 or sign(x) == 1) and sign(y) == -1 -> :north_east
      sign(x) == 1 and (sign(y) == 0 or sign(y) == 1) -> :south_east
      (sign(x) == 0 or sign(x) == -1) and sign(y) == 1 -> :south_west
      sign(x) == -1 and (sign(y) == 0 or sign(y) == -1) -> :north_west
    end
  end

  defp sign(0), do: 0
  defp sign(n) when n > 0, do: 1
  defp sign(n) when n < 0, do: -1

  def part2(%{}) do
    :not_done
  end
end
