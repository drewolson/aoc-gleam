import aoc/util/parser
import gleeunit/should

pub fn int_test() {
  "123"
  |> parser.go(parser.int())
  |> should.equal(123)
}

pub fn signed_int_positive_test() {
  "+123"
  |> parser.go(parser.signed_int())
  |> should.equal(123)
}

pub fn signed_int_negative_test() {
  "-123"
  |> parser.go(parser.signed_int())
  |> should.equal(-123)
}
