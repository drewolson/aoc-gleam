import aoc/year2024/day12

const input = "RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE
"

pub fn part1_test() {
  assert day12.part1(input) == 1930
}

pub fn part2_test() {
  assert day12.part2(input) == 1206
}
