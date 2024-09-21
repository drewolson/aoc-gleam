import gleam/regex.{type Regex}

pub fn from_string(str: String) -> Regex {
  let assert Ok(re) = regex.from_string(str)
  re
}
