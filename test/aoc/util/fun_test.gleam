import aoc/util/fun
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

  use n <- qcheck.given(qcheck.int_small_positive_or_zero())

  fact_fix(n) == fact_regular(n)
}
