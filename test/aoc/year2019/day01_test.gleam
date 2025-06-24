import aoc/year2019/day01

const input = "12
14
1969
100756
"

const input2 = "14
1969
100756
"

pub fn part1_test() {
  assert day01.part1(input) == 34_241
}

pub fn part2_test() {
  assert day01.part2(input2) == 51_314
}
