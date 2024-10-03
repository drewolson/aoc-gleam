pub opaque type State(s, a) {
  State(f: fn(s) -> #(a, s))
}

pub fn new(f: fn(s) -> #(a, s)) -> State(s, a) {
  State(f)
}

pub fn return(a: a) -> State(s, a) {
  State(fn(s) { #(a, s) })
}

pub fn get() -> State(s, s) {
  State(fn(s) { #(s, s) })
}

pub fn put(s: s) -> State(s, Nil) {
  State(fn(_) { #(Nil, s) })
}

pub fn modify(f: fn(s) -> s) -> State(s, Nil) {
  State(fn(s) { #(Nil, f(s)) })
}

pub fn run(state: State(s, a), s: s) -> #(a, s) {
  state.f(s)
}

pub fn eval(state: State(s, a), s: s) -> a {
  run(state, s).0
}

pub fn exec(state: State(s, a), s: s) -> s {
  run(state, s).1
}

pub fn do(state: State(s, a), f: fn(a) -> State(s, b)) -> State(s, b) {
  State(fn(s) {
    let #(a, s1) = run(state, s)

    run(f(a), s1)
  })
}

pub fn map(state: State(s, a), f: fn(a) -> b) -> State(s, b) {
  use a <- do(state)

  return(f(a))
}

pub fn apply(sf: State(s, fn(a) -> b), sa: State(s, a)) -> State(s, b) {
  use f <- do(sf)
  use a <- do(sa)

  return(f(a))
}

pub fn gets(f: fn(s) -> a) -> State(s, a) {
  get() |> map(f)
}

pub fn with_state(f: fn(s) -> s, state: State(s, a)) -> State(s, a) {
  use Nil <- do(modify(f))

  state
}
