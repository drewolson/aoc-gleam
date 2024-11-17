import gleam/string

pub fn lines(str: String) -> List(String) {
  str
  |> string.trim_end
  |> string.split("\n")
}
