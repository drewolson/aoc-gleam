import aoc/util/hashtbl.{type Hashtbl}

type MemoFn(a, b) =
  fn(fn(a) -> b, a) -> b

fn memoize_aux(cache: Hashtbl(a, b), f: MemoFn(a, b)) -> fn(a) -> b {
  fn(a: a) -> b {
    hashtbl.get_or(cache, a, fn() { f(memoize_aux(cache, f), a) })
  }
}

pub fn memoize(f: MemoFn(a, b), k: fn(fn(a) -> b) -> c) -> c {
  use hashtbl <- hashtbl.new()
  k(memoize_aux(hashtbl, f))
}
