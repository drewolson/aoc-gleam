import aoc/year2024/day01
import aoc/year2024/day02
import aoc/year2024/day03
import aoc/year2024/day04
import aoc/year2024/day05
import aoc/year2024/day06
import aoc/year2024/day07
import aoc/year2024/day08
import aoc/year2024/day09
import aoc/year2024/day10
import aoc/year2024/day11
import aoc/year2024/day12
import aoc/year2024/day13
import gleam/string

pub fn run(input: String, day: Int, part: Int) {
  case day, part {
    1, 1 -> input |> day01.part1 |> string.inspect
    1, 2 -> input |> day01.part2 |> string.inspect
    2, 1 -> input |> day02.part1 |> string.inspect
    2, 2 -> input |> day02.part2 |> string.inspect
    3, 1 -> input |> day03.part1 |> string.inspect
    3, 2 -> input |> day03.part2 |> string.inspect
    4, 1 -> input |> day04.part1 |> string.inspect
    4, 2 -> input |> day04.part2 |> string.inspect
    5, 1 -> input |> day05.part1 |> string.inspect
    5, 2 -> input |> day05.part2 |> string.inspect
    6, 1 -> input |> day06.part1 |> string.inspect
    6, 2 -> input |> day06.part2 |> string.inspect
    7, 1 -> input |> day07.part1 |> string.inspect
    7, 2 -> input |> day07.part2 |> string.inspect
    8, 1 -> input |> day08.part1 |> string.inspect
    8, 2 -> input |> day08.part2 |> string.inspect
    9, 1 -> input |> day09.part1 |> string.inspect
    9, 2 -> input |> day09.part2 |> string.inspect
    10, 1 -> input |> day10.part1 |> string.inspect
    10, 2 -> input |> day10.part2 |> string.inspect
    11, 1 -> input |> day11.part1 |> string.inspect
    11, 2 -> input |> day11.part2 |> string.inspect
    12, 1 -> input |> day12.part1 |> string.inspect
    12, 2 -> input |> day12.part2 |> string.inspect
    13, 1 -> input |> day13.part1 |> string.inspect
    13, 2 -> input |> day13.part2 |> string.inspect
    _, _ ->
      "Unknown day and part for 2024: day "
      <> string.inspect(day)
      <> ", part "
      <> string.inspect(part)
  }
}
