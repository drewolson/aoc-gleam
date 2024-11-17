import aoc/runner/year2023
import aoc/runner/year2024
import gleam/result
import gleam/string
import simplifile

pub fn run(year: Int, day: Int, part: Int) {
  let year_str = string.inspect(year)
  let day_str = day |> string.inspect |> string.pad_start(2, "0")
  let path = "./data/" <> year_str <> "/day" <> day_str <> ".txt"
  use content <- result.try(
    path
    |> simplifile.read
    |> result.replace_error("Could not read file: " <> path),
  )

  case year {
    2023 -> year2023.run(content, day, part)
    2024 -> year2024.run(content, day, part)
    _ -> "Unkown year: " <> year_str
  }
  |> Ok
}
