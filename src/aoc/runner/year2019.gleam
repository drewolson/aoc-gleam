import aoc/year2019/day01
import aoc/year2019/day02
import gleam/string

pub fn run(input: String, day: Int, part: Int) -> String {
  case day, part {
    1, 1 -> input |> day01.part1 |> string.inspect
    1, 2 -> input |> day01.part2 |> string.inspect
    2, 1 -> input |> day02.part1 |> string.inspect
    2, 2 -> input |> day02.part2 |> string.inspect
    _, _ ->
      "Unknown day and part for 2019: day "
      <> string.inspect(day)
      <> ", part "
      <> string.inspect(part)
  }
}
