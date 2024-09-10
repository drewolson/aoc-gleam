import aoc/util
import gleam/int
import gleam/list
import gleam/regex
import gleam/result
import gleam/string

fn to_digit(line: String) -> Result(Int, Nil) {
  use re <- result.try(util.make_regex("[0-9]"))
  let f_match = regex.scan(re, line)
  let b_match = regex.scan(re, string.reverse(line))

  case f_match, b_match {
    [a, ..], [b, ..] -> int.parse(a.content <> b.content)
    _, _ -> Error(Nil)
  }
}

pub fn part1(input: String) -> Int {
  input
  |> util.lines
  |> list.filter_map(to_digit)
  |> list.fold(0, fn(a, b) { a + b })
}
