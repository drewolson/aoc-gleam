import aoc/util/fun
import gleeunit/should

pub fn fix_test() {
  let fact =
    fun.fix(fn(recur, n) {
      case n {
        0 | 1 -> 1
        n -> n * recur(n - 1)
      }
    })

  fact(5) |> should.equal(120)
}
