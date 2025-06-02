import aoc/year2024/day19

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
  assert day19.part1(input) == 6
}

pub fn part2_test() {
  assert day19.part2(input) == 16
}
