import aoc/year2023/day01
import gleeunit/should

const input = "
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
"

pub fn part1_test() {
  input
  |> day01.part1
  |> should.equal(142)
}
