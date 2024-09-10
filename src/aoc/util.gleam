import gleam/regex.{type Regex}
import gleam/result
import gleam/string

pub fn make_regex(str: String) -> Result(Regex, Nil) {
  str
  |> regex.from_string()
  |> result.map_error(fn(_) { Nil })
}

pub fn lines(str: String) -> List(String) {
  str
  |> string.trim_right
  |> string.split("\n")
}
