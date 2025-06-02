import aoc/year2024/day03

const input1 = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"

const input2 = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"

pub fn part1_test() {
  assert day03.part1(input1) == 161
}

pub fn part2_test() {
  assert day03.part2(input2) == 48
}
