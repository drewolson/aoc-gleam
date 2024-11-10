import aoc/year2024/day01
import gleeunit/should

const input = "something"

pub fn part1_test() {
  input
  |> day01.part1
  |> should.equal(1)
}

pub fn part2_test() {
  input
  |> day01.part2
  |> should.equal(2)
}
