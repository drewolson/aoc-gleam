import aoc/year2024/day04
import gleeunit/should

const input = "MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
"

pub fn part1_test() {
  input
  |> day04.part1
  |> should.equal(18)
}

pub fn part2_test() {
  input
  |> day04.part2
  |> should.equal(9)
}
