import aoc/year2023/day14
import gleeunit/should

const input = "
O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....
"

pub fn part1_test() {
  input
  |> day14.part1
  |> should.equal(136)
}

pub fn part2_test() {
  input
  |> day14.part2
  |> should.equal(64)
}
