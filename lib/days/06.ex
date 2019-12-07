defmodule AdventOfCode.Day6 do
  @behaviour AdventOfCode

  def setup(input) do
    orbits =
      input
      |> String.trim()
      |> String.split()
      |> Enum.map(&String.split(&1, ")"))

    %{orbits: orbits}
  end

  def part1(%{orbits: orbits}) do
    orbits
    |> build_dag()
    |> total_orbits()
  end

  defp build_dag(orbits) do
    Enum.reduce(orbits, DAG.new(), fn [orbitee, orbiter], dag ->
      DAG.add(dag, orbiter, orbitee)
    end)
  end

  defp total_orbits(dag) do
    dag
    |> Map.keys()
    |> Enum.reduce(0, fn object, count ->
      count + orbits(object, dag, "COM")
    end)
  end

  defp orbits(object, dag, target) do
    orbits(object, dag, target, 0)
  end

  defp orbits(target, _dag, target, count), do: count

  defp orbits(object, dag, target, count) do
    orbits(Map.get(dag, object), dag, target, count + 1)
  end

  def part2(%{orbits: orbits}) do
    dag = build_dag(orbits)
    source = dag["YOU"]
    dest = dag["SAN"]

    common = DAG.first_common_ancestor(dag, source, dest)
    orbits(source, dag, common) + orbits(dest, dag, common)
  end
end

defmodule DAG do
  def new do
    %{}
  end

  def add(dag, child, parent) do
    dag
    |> Map.put_new(parent, nil)
    |> Map.put(child, parent)
  end

  def first_common_ancestor(dag, a, b) do
    a_ancestors = all_ancestors(dag, a)
    common_ancestor(dag, b, a_ancestors)
  end

  defp common_ancestor(_dag, nil, _a_ancestors), do: :no_common_ancestor

  defp common_ancestor(dag, node, a_ancestors) do
    if MapSet.member?(a_ancestors, node) do
      node
    else
      common_ancestor(dag, Map.get(dag, node), a_ancestors)
    end
  end

  defp all_ancestors(dag, node) do
    all_ancestors(dag, node, MapSet.new())
  end

  defp all_ancestors(dag, node, ancestors) do
    parent = Map.get(dag, node)

    if parent == nil do
      ancestors
    else
      all_ancestors(dag, parent, MapSet.put(ancestors, parent))
    end
  end
end
