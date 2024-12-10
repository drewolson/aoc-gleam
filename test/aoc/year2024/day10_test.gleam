import aoc/year2024/day10
import glacier/should

const input = "89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732
"

pub fn part1_test() {
  input
  |> day10.part1
  |> should.equal(36)
}

pub fn part2_test() {
  input
  |> day10.part2
  |> should.equal(81)
}
