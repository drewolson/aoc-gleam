import gleam/regexp.{type Regexp}

pub fn from_string(str: String) -> Regexp {
  let assert Ok(re) = regexp.from_string(str)
  re
}
