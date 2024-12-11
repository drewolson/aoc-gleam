import aoc/year2024/day11
import glacier/should

const input = "125 17"

pub fn part1_test() {
  input
  |> day11.part1
  |> should.equal(55_312)
}
