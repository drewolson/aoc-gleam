import aoc/util/parser
import gleam/int
import pears
import qcheck

pub fn int_test() {
  use n <- qcheck.given(qcheck.small_non_negative_int())

  let result =
    n
    |> int.to_string
    |> pears.parse_string_all(parser.int())

  assert result == Ok(n)
}

pub fn signed_int_positive_test() {
  use n <- qcheck.given(qcheck.small_non_negative_int())

  let input = "+" <> int.to_string(n)
  let result = pears.parse_string_all(input, parser.signed_int())

  assert result == Ok(n)
}

pub fn signed_int_negative_test() {
  use n <- qcheck.given(qcheck.small_non_negative_int())

  let input = "-" <> int.to_string(n)
  let result = pears.parse_string_all(input, parser.signed_int())

  assert result == Ok(-n)
}
