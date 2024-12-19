import aoc/year2024/day12
import gleeunit/should

const input = "RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE
"

pub fn part1_test() {
  input
  |> day12.part1
  |> should.equal(1930)
}

pub fn part2_test() {
  input
  |> day12.part2
  |> should.equal(1206)
}
