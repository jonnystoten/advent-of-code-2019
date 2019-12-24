defmodule AdventOfCode.Day14 do
  @behaviour AdventOfCode

  def setup(input) do
    graph =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_line/1)
      |> Map.new()

    %{graph: graph}
  end

  defp parse_line(line) do
    [deps, result] =
      line
      |> String.split(" => ")

    deps =
      deps
      |> String.split(", ")
      |> Enum.map(&resource_and_quantity/1)

    {resource, quantity} = resource_and_quantity(result)

    {resource, {quantity, deps}}
  end

  defp resource_and_quantity(str) do
    [quantity, resource] = String.split(str, " ")
    {resource, String.to_integer(quantity)}
  end

  def part1(%{graph: graph}) do
    ore_required(1, "FUEL", graph)
  end

  defp ore_required(quantity, resource, graph) do
    {result, _} = ore_required(quantity, resource, Map.new(), graph)
    result
  end

  defp ore_required(0, _resouce, surplus, _graph), do: {0, surplus}
  defp ore_required(quantity, "ORE", surplus, _graph), do: {quantity, surplus}

  defp ore_required(quantity, resource, surplus, graph) do
    {provided, deps} = graph[resource]

    already_have = Map.get(surplus, resource, 0)

    multiples_required = ceil((quantity - already_have) / provided)

    {ores_for_each_dep, surplus} =
      Enum.map_reduce(deps, surplus, fn {r, q}, surplus ->
        ore_required(q * multiples_required, r, surplus, graph)
      end)

    ore_for_one = Enum.sum(ores_for_each_dep)

    leftover = multiples_required * provided - quantity
    surplus = Map.update(surplus, resource, leftover, &(&1 + leftover))
    {ore_for_one, surplus}
  end

  def part2(%{graph: graph}) do
    binary_search(1, 1_000_000_000, &ore_required(&1, "FUEL", graph), 1_000_000_000_000)
  end

  defp binary_search(same, same, _, _), do: same

  defp binary_search(low, high, func, target) do
    mid = low + div(high - low, 2)
    result = func.(mid)

    cond do
      result < target -> binary_search(mid + 1, high, func, target)
      result > target -> binary_search(low, mid - 1, func, target)
      result == target -> mid
    end
  end
end
