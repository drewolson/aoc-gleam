import aoc/year2024/day01
import gleeunit/should

const input = "3   4
4   3
2   5
1   3
3   9
3   3
"

pub fn part1_test() {
  input
  |> day01.part1
  |> should.equal(11)
}

pub fn part2_test() {
  input
  |> day01.part2
  |> should.equal(31)
}
