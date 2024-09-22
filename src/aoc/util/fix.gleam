pub type FixFn(a, b) =
  fn(fn(a) -> b, a) -> b

pub fn fix(f: FixFn(a, b)) -> fn(a) -> b {
  fn(a: a) -> b { f(fix(f), a) }
}
