defmodule Day1 do
  def part1(input) do
    input
    |> Enum.map(&fuel/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
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

input = """
120333
142772
85755
90217
74894
86021
66768
147353
67426
145635
100070
88290
110673
109887
91389
121365
52760
58613
130918
57842
80622
50466
80213
85816
149832
133813
60211
69491
129415
141471
77916
98907
63440
109545
80183
143073
77783
88546
149648
128010
55530
54878
103885
57312
81011
148450
137947
67252
106264
149860
71677
101209
128477
112159
56027
53313
118916
98057
131668
61605
107488
65517
63594
84072
79214
141606
137375
112525
64572
126216
57013
130003
122450
50642
136844
96272
97861
59071
106870
116595
144966
88723
124038
63629
105304
52928
92917
147571
120553
113823
85524
71152
95199
102000
118874
133317
146849
60450
103307
117162
"""

input = input
|> String.split()
|> Enum.map(&String.to_integer/1)

Day1.part1(input)
|> IO.puts()

Day1.part2(input)
|> IO.puts()
