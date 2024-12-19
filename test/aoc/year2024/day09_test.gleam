import aoc/year2024/day09
import gleeunit/should

const input = "2333133121414131402"

pub fn part1_test() {
  input
  |> day09.part1
  |> should.equal(1928)
}

pub fn part2_test() {
  input
  |> day09.part2
  |> should.equal(2858)
}
