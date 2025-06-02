import aoc/year2023/day01

const input = "1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
"

const input2 = "two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
"

pub fn part1_test() {
  assert day01.part1(input) == 142
}

pub fn part2_test() {
  assert day01.part2(input2) == 281
}
