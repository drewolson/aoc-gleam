import aoc/year2024/day04

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
  assert day04.part1(input) == 18
}

pub fn part2_test() {
  assert day04.part2(input) == 9
}
