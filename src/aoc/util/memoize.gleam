import aoc/util/fix.{type FixFn}
import aoc/util/hashtbl

pub fn memoize(f: FixFn(a, b), k: fn(fn(a) -> b) -> c) -> c {
  use cache <- hashtbl.new()

  let aux =
    fix.fix(fn(recur, a) { hashtbl.get_or_lazy(cache, a, fn() { f(recur, a) }) })

  k(aux)
}
