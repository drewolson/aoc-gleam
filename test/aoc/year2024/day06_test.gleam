import aoc/year2024/day06
import gleeunit/should

const input = "....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...
"

pub fn part1_test() {
  input
  |> day06.part1
  |> should.equal(41)
}

pub fn part2_test() {
  input
  |> day06.part2
  |> should.equal(6)
}
