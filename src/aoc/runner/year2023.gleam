import aoc/year2023/day01
import aoc/year2023/day02
import aoc/year2023/day09
import aoc/year2023/day14
import gleam/string

pub fn run(input: String, day: Int, part: Int) -> String {
  case day, part {
    1, 1 -> input |> day01.part1 |> string.inspect
    1, 2 -> input |> day01.part2 |> string.inspect
    2, 1 -> input |> day02.part1 |> string.inspect
    2, 2 -> input |> day02.part2 |> string.inspect
    9, 1 -> input |> day09.part1 |> string.inspect
    9, 2 -> input |> day09.part2 |> string.inspect
    14, 1 -> input |> day14.part1 |> string.inspect
    14, 2 -> input |> day14.part2 |> string.inspect
    _, _ ->
      "Unknown day and part for 2023: day "
      <> string.inspect(day)
      <> ", part "
      <> string.inspect(part)
  }
}
