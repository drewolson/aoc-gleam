import aoc/year2024/day02

const input = "7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
"

pub fn part1_test() {
  assert day02.part1(input) == 2
}

pub fn part2_test() {
  assert day02.part2(input) == 4
}
