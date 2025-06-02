import aoc/year2024/day01

const input = "3   4
4   3
2   5
1   3
3   9
3   3
"

pub fn part1_test() {
  assert day01.part1(input) == 11
}

pub fn part2_test() {
  assert day01.part2(input) == 31
}
