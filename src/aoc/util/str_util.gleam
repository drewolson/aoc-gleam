import gleam/string

pub fn lines(str: String) -> List(String) {
  str
  |> string.trim_right
  |> string.split("\n")
}
