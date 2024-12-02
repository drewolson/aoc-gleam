import aoc/util/parser
import gleam/int
import party
import qcheck

pub fn int_test() {
  use n <- qcheck.given(qcheck.small_positive_or_zero_int())

  let result =
    n
    |> int.to_string
    |> party.go(parser.int(), _)

  result == Ok(n)
}

pub fn signed_int_positive_test() {
  use n <- qcheck.given(qcheck.small_positive_or_zero_int())

  let input = "+" <> int.to_string(n)
  let result = party.go(parser.signed_int(), input)

  result == Ok(n)
}

pub fn signed_int_negative_test() {
  use n <- qcheck.given(qcheck.small_positive_or_zero_int())

  let input = "-" <> int.to_string(n)
  let result = party.go(parser.signed_int(), input)

  result == Ok(-n)
}

pub fn drop_test() {
  use #(a, b) <- qcheck.given(qcheck.tuple2(
    qcheck.string_non_empty(),
    qcheck.string_non_empty(),
  ))

  let input = a <> b
  let p = {
    use <- parser.drop(party.string(a))
    use b <- party.do(party.string(b))
    party.return(b)
  }
  let result = party.go(p, input)

  result == Ok(b)
}
