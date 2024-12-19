import aoc/year2024/day19
import gleeunit/should

const input = "r, wr, b, g, bwu, rb, gb, br

brwrr
bggr
gbbr
rrbgbr
ubwu
bwurrg
brgr
bbrgwb
"

pub fn part1_test() {
  input
  |> day19.part1
  |> should.equal(6)
}

pub fn part2_test() {
  input
  |> day19.part2
  |> should.equal(16)
}
