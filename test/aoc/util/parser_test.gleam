import aoc/util/parser
import gleam/int
import gleeunit/should
import party
import qcheck

pub fn int_test() {
  use n <- qcheck.given(qcheck.small_non_negative_int())

  let result =
    n
    |> int.to_string
    |> party.go(parser.int(), _)

  result
  |> should.equal(Ok(n))
}

pub fn signed_int_positive_test() {
  use n <- qcheck.given(qcheck.small_non_negative_int())

  let input = "+" <> int.to_string(n)
  let result = party.go(parser.signed_int(), input)

  result
  |> should.equal(Ok(n))
}

pub fn signed_int_negative_test() {
  use n <- qcheck.given(qcheck.small_non_negative_int())

  let input = "-" <> int.to_string(n)
  let result = party.go(parser.signed_int(), input)

  result
  |> should.equal(Ok(-n))
}
