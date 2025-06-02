import aoc/year2023/day14

const input = "O....#....
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
  assert day14.part1(input) == 136
}

pub fn part2_test() {
  assert day14.part2(input) == 64
}
