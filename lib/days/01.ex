defmodule AdventOfCode.Day1 do
  @behaviour AdventOfCode

  def setup(input) do
    masses =
      input
      |> String.split()
      |> Enum.map(&String.to_integer/1)

    %{masses: masses}
  end

  def part1(%{masses: masses}) do
    masses
    |> Enum.map(&fuel/1)
    |> Enum.sum()
  end

  def part2(%{masses: masses}) do
    masses
    |> Enum.map(&total_fuel/1)
    |> Enum.sum()
  end

  defp total_fuel(mass) do
    total_fuel(mass, 0)
  end

  defp total_fuel(mass, fuel_so_far) do
    fuel_for_mass = fuel(mass)

    if fuel_for_mass <= 0 do
      fuel_so_far
    else
      total_fuel(fuel_for_mass, fuel_so_far + fuel_for_mass)
    end
  end

  defp fuel(mass) do
    div(mass, 3) - 2
  end
end
