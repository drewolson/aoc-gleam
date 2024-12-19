import aoc/util/state.{type State}
import gleam/dict.{type Dict}

pub type Cache(k, v) =
  State(Dict(k, v), v)

pub fn do_cached(key: k, f: fn() -> Cache(k, v)) -> Cache(k, v) {
  use res <- state.do(state.gets(dict.get(_, key)))
  case res {
    Ok(value) -> state.return(value)
    Error(_) -> {
      use value <- state.do(f())
      use _ <- state.do(state.modify(dict.insert(_, key, value)))
      state.return(value)
    }
  }
}

pub fn run(cache: Cache(k, v)) -> v {
  state.eval(cache, dict.new())
}
