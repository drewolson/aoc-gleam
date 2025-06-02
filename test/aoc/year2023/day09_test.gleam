import aoc/year2023/day09

const input = "0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
"

pub fn part1_test() {
  assert day09.part1(input) == 114
}

pub fn part2_test() {
  assert day09.part2(input) == 2
}
