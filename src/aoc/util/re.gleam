import gleam/regex.{type Regex}

pub fn make_regex(str: String) -> Regex {
  let assert Ok(re) = regex.from_string(str)
  re
}
