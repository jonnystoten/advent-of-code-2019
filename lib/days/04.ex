defmodule AdventOfCode.Day4 do
  @behaviour AdventOfCode

  def setup(input) do
    [min, max] =
      input
      |> String.split("-")
      |> Enum.map(&String.to_integer/1)

    %{min: min, max: max}
  end

  def part1(%{min: min, max: max}) do
    valid_passwords_count(min, max, false)
  end

  def part2(%{min: min, max: max}) do
    valid_passwords_count(min, max, true)
  end

  defp valid_passwords_count(min, max, exact_doubles) do
    Enum.reduce(min..max, 0, fn password, count ->
      if valid_password?(password, exact_doubles) do
        count + 1
      else
        count
      end
    end)
  end

  defp valid_password?(password, exact_doubles) do
    digits = Integer.digits(password)

    has_double =
      digits
      |> Enum.reduce(%{}, fn digit, map ->
        Map.update(map, digit, 1, &(&1 + 1))
      end)
      |> Enum.any?(fn {_k, v} ->
        if exact_doubles do
          v == 2
        else
          v >= 2
        end
      end)

    has_double and ascending_only?(digits)
  end

  defp ascending_only?([]), do: true
  defp ascending_only?([a, b | _]) when a > b, do: false
  defp ascending_only?([_ | tail]), do: ascending_only?(tail)
end
