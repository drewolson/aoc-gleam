import aoc/year2023/day01
import gleam/string

pub fn run(input: String, day: Int, part: Int) {
  case day, part {
    1, 1 -> input |> day01.part1 |> string.inspect
    1, 2 -> input |> day01.part2 |> string.inspect
    _, _ ->
      "Unknown day and part: day "
      <> string.inspect(day)
      <> ", part "
      <> string.inspect(part)
  }
}
