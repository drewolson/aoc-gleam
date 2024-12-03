import aoc/year2024/day03
import glacier/should

const input1 = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"

const input2 = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"

pub fn part1_test() {
  input1
  |> day03.part1
  |> should.equal(161)
}

pub fn part2_test() {
  input2
  |> day03.part2
  |> should.equal(48)
}
