defmodule Day4 do
  def part1(min, max) do
    valid_passwords_count(min, max, false)
  end

  def part2(min, max) do
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

    pairs = Enum.zip(digits, tl(digits))

    valid =
      Enum.reduce_while(pairs, true, fn {a, b}, _valid ->
        cond do
          a > b -> {:halt, false}
          true -> {:cont, true}
        end
      end)

    valid and has_double
  end
end

input = "109165-576723"

[min, max] =
  input
  |> String.split("-")
  |> Enum.map(&String.to_integer/1)

Day4.part1(min, max)
|> IO.puts()

Day4.part2(min, max)
|> IO.puts()
