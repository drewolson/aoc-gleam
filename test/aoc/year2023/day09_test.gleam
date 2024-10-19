import aoc/year2023/day09
import gleeunit/should

const input = "0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
"

pub fn part1_test() {
  input
  |> day09.part1
  |> should.equal(114)
}

pub fn part2_test() {
  input
  |> day09.part2
  |> should.equal(2)
}
