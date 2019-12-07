defmodule AdventOfCode.Day3 do
  @behaviour AdventOfCode

  def setup(input) do
    wires =
      input
      |> String.trim()
      |> String.split()
      |> Enum.map(fn line ->
        String.split(line, ",")
      end)

    %{wires: wires}
  end

  def part1(%{wires: wires}) do
    wires
    |> parse_wires()
    |> find_intersections()
    |> Enum.map(fn {x, y} -> x + y end)
    |> Enum.sort()
    |> hd()
  end

  defp parse_wires(wires) do
    Enum.map(wires, fn wire ->
      Enum.map(wire, &parse/1)
    end)
  end

  defp find_intersections(wires) do
    wires
    |> Enum.map(&trace_route/1)
    |> Enum.reduce(&MapSet.intersection/2)
    |> MapSet.difference(MapSet.new([{0, 0}]))
  end

  def part2(%{wires: wires}) do
    parsed_wires = parse_wires(wires)
    intersections = find_intersections(parsed_wires)

    parsed_wires
    |> Enum.reduce(Map.new(), fn wire, map ->
      wire
      |> distance_to_intersections(intersections)
      |> Map.merge(map, fn _k, a, b -> a + b end)
    end)
    |> Enum.map(fn {_k, v} -> v end)
    |> Enum.sort()
    |> hd()
  end

  defp trace_route(wire) do
    trace_route(wire, {0, 0}, MapSet.new())
  end

  defp trace_route([], _cursor, grid), do: grid

  defp trace_route([path | tail], cursor, grid) do
    {cursor, grid} = trace_path(path, cursor, grid)
    trace_route(tail, cursor, grid)
  end

  defp trace_path({_dir, 0}, cursor, grid), do: {cursor, grid}

  defp trace_path({dir, distance}, cursor, grid) do
    next = next_space(dir, cursor)
    trace_path({dir, distance - 1}, next, MapSet.put(grid, cursor))
  end

  defp distance_to_intersections(wire, intersections) do
    distance_to_intersections(wire, 0, intersections, {0, 0}, Map.new())
  end

  defp distance_to_intersections(_wire, _distance, %MapSet{map: map}, _cursor, results)
       when map_size(map) == 0 do
    results
  end

  defp distance_to_intersections([path | tail], distance, intersections, cursor, results) do
    {distance, intersections, cursor, results} =
      path_distance(path, distance, intersections, cursor, results)

    distance_to_intersections(tail, distance, intersections, cursor, results)
  end

  defp path_distance({_dir, 0}, distance, intersections, cursor, results),
    do: {distance, intersections, cursor, results}

  defp path_distance({dir, path_distance}, distance, intersections, cursor, results) do
    {intersections, results} =
      if MapSet.member?(intersections, cursor) do
        {MapSet.delete(intersections, cursor), Map.put(results, cursor, distance)}
      else
        {intersections, results}
      end

    next = next_space(dir, cursor)
    path_distance({dir, path_distance - 1}, distance + 1, intersections, next, results)
  end

  defp next_space(:up, {x, y}), do: {x, y + 1}
  defp next_space(:right, {x, y}), do: {x + 1, y}
  defp next_space(:down, {x, y}), do: {x, y - 1}
  defp next_space(:left, {x, y}), do: {x - 1, y}

  defp parse("U" <> rest) do
    {:up, String.to_integer(rest)}
  end

  defp parse("R" <> rest) do
    {:right, String.to_integer(rest)}
  end

  defp parse("D" <> rest) do
    {:down, String.to_integer(rest)}
  end

  defp parse("L" <> rest) do
    {:left, String.to_integer(rest)}
  end
end
