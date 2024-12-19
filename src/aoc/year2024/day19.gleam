import aoc/util/state.{type State}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/string

type Cache(a) =
  State(Dict(String, a), a)

fn parse(input: String) -> #(List(String), List(String)) {
  let order = fn(a, b) { int.compare(string.length(b), string.length(a)) }
  let assert Ok(#(a, b)) =
    input
    |> string.trim_end
    |> string.split_once("\n\n")

  let patterns = a |> string.split(", ") |> list.sort(order)
  let designs = string.split(b, "\n")

  #(patterns, designs)
}

fn do_cached(key: String, f: fn() -> Cache(Int)) -> Cache(Int) {
  use res <- state.do(state.gets(dict.get(_, key)))
  case res {
    Ok(v) -> state.return(v)
    Error(_) -> {
      use v <- state.do(f())
      use _ <- state.do(state.modify(dict.insert(_, key, v)))
      state.return(v)
    }
  }
}

fn is_valid(design: String, patterns: List(String)) -> Cache(Int) {
  do_cached(design, fn() {
    case string.is_empty(design) {
      True -> state.return(1)
      False -> {
        list.fold(patterns, state.return(0), fn(sacc, pattern) {
          use acc <- state.do(sacc)
          use res <- state.do(case string.starts_with(design, pattern) {
            False -> state.return(0)
            True ->
              is_valid(
                string.drop_start(design, string.length(pattern)),
                patterns,
              )
          })

          state.return(acc + res)
        })
      }
    }
  })
}

pub fn part1(input: String) -> Int {
  let #(patterns, designs) = parse(input)

  designs
  |> list.fold(state.return(0), fn(sacc, design) {
    use acc <- state.do(sacc)
    use res <- state.do(is_valid(design, patterns))
    state.return(case res > 0 {
      True -> acc + 1
      False -> acc
    })
  })
  |> state.eval(dict.new())
}

pub fn part2(input: String) -> Int {
  let #(patterns, designs) = parse(input)

  designs
  |> list.fold(state.return(0), fn(sacc, design) {
    use acc <- state.do(sacc)
    use res <- state.do(is_valid(design, patterns))
    state.return(acc + res)
  })
  |> state.eval(dict.new())
}
