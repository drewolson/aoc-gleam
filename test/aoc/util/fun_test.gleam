import aoc/util/fun
import gleeunit/should
import qcheck

fn fact_regular(n) {
  case n {
    0 | 1 -> 1
    n -> n * fact_regular(n - 1)
  }
}

pub fn fix_test() {
  let fact_fix =
    fun.fix(fn(recur, n) {
      case n {
        0 | 1 -> 1
        n -> n * recur(n - 1)
      }
    })

  use n <- qcheck.given(qcheck.small_non_negative_int())

  fact_fix(n)
  |> should.equal(fact_regular(n))
}
