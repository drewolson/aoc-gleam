import aoc/runner/year2023
import gleam/result
import gleam/string

@external(erlang, "file", "read_file")
fn read_file(path: String) -> Result(String, String)

pub fn run(year: Int, day: Int, part: Int) {
  let year_str = string.inspect(year)
  let day_str = day |> string.inspect |> string.pad_left(2, "0")
  let path = "./data/" <> year_str <> "/day" <> day_str <> ".txt"
  use content <- result.try(read_file(path))

  case year {
    2023 -> year2023.run(content, day, part)
    _ -> "Unkown year: " <> year_str
  }
  |> Ok
}
