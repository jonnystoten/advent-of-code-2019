defmodule AdventOfCode.Day12 do
  @behaviour AdventOfCode

  def setup(input) do
    moons =
      input
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&parse_line/1)

    %{moons: moons}
  end

  defp parse_line(line) do
    regex = ~r/<x=(?<x>-?\d+), y=(?<y>-?\d+), z=(?<z>-?\d+)>/

    position =
      Regex.named_captures(regex, line)
      |> Map.new(fn {k, v} -> {String.to_atom(k), String.to_integer(v)} end)

    %{position: position, velocity: %{x: 0, y: 0, z: 0}}
  end

  def part1(%{moons: moons}) do
    moons
    |> simulate(1000)
    |> total_energy()
  end

  defp simulate(moons, 0), do: moons

  defp simulate(moons, t) do
    moons
    |> apply_gravity()
    |> apply_velocity()
    |> simulate(t - 1)
  end

  defp apply_gravity(moons) do
    moons
    |> Enum.map(fn moon ->
      other_moons = Enum.reject(moons, &(&1 == moon))
      apply_gravity(moon, other_moons)
    end)
  end

  defp apply_gravity(moon, other_moons) do
    Enum.reduce([:x, :y, :z], moon, fn axis, moon ->
      adjustment =
        other_moons
        |> Enum.map(fn other_moon ->
          cond do
            moon.position[axis] < other_moon.position[axis] -> 1
            moon.position[axis] > other_moon.position[axis] -> -1
            moon.position[axis] == other_moon.position[axis] -> 0
          end
        end)
        |> Enum.sum()

      new_vel = moon.velocity[axis] + adjustment
      %{moon | velocity: Map.put(moon.velocity, axis, new_vel)}
    end)
  end

  defp apply_velocity(moons) do
    moons
    |> Enum.map(fn moon ->
      %{moon | position: add(moon.position, moon.velocity)}
    end)
  end

  defp total_energy(moons) do
    moons
    |> Enum.map(fn moon ->
      potential_energy(moon) * kinetic_energy(moon)
    end)
    |> Enum.sum()
  end

  defp potential_energy(moon) do
    energy_sum(moon, :position)
  end

  defp kinetic_energy(moon) do
    energy_sum(moon, :velocity)
  end

  defp energy_sum(moon, type) do
    moon
    |> Map.fetch!(type)
    |> Map.values()
    |> Enum.map(&abs(&1))
    |> Enum.sum()
  end

  defp add(vec1, vec2) do
    %{x: vec1.x + vec2.x, y: vec1.y + vec2.y, z: vec1.z + vec2.z}
  end

  def part2(%{moons: moons}) do
    simulate_until_repeat(moons)
  end

  defp simulate_until_repeat(moons) do
    simulate_until_repeat(moons, 0, MapSet.new())
  end

  defp simulate_until_repeat(moons, t, previous_states) do
    new_state =
      moons
      |> apply_gravity()
      |> apply_velocity()

    if MapSet.member?(previous_states, new_state) do
      t
    else
      simulate_until_repeat(new_state, t + 1, MapSet.put(previous_states, new_state))
    end
  end
end
