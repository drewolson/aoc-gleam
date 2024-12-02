import aoc/util/re
import gleam/int
import gleam/list
import gleam/regexp.{type Regexp}
import gleam/string

fn whitespace() -> Regexp {
  re.from_string("\\s+")
}

pub fn lines(str: String) -> List(String) {
  str
  |> string.trim_end
  |> string.split("\n")
}

pub fn nums(str: String) -> List(Int) {
  whitespace()
  |> regexp.split(str)
  |> list.filter_map(int.parse)
}
