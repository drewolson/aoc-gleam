import aoc/util/cache.{type Cache}
import aoc/util/state
import gleam/list
import gleam/string

fn parse(input: String) -> #(List(String), List(String)) {
  let assert Ok(#(a, b)) =
    input
    |> string.trim_end
    |> string.split_once("\n\n")
  let patterns = string.split(a, ", ")
  let designs = string.split(b, "\n")

  #(patterns, designs)
}

fn valid_combos(design: String, patterns: List(String)) -> Cache(String, Int) {
  cache.get_or(design, fn() {
    case string.is_empty(design) {
      True -> state.return(1)
      False -> {
        list.fold(patterns, state.return(0), fn(sacc, pattern) {
          use acc <- state.do(sacc)
          use res <- state.do(case string.starts_with(design, pattern) {
            False -> state.return(0)
            True ->
              valid_combos(
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
    use res <- state.do(valid_combos(design, patterns))
    state.return(case res > 0 {
      True -> acc + 1
      False -> acc
    })
  })
  |> cache.run
}

pub fn part2(input: String) -> Int {
  let #(patterns, designs) = parse(input)

  designs
  |> list.fold(state.return(0), fn(sacc, design) {
    use acc <- state.do(sacc)
    use res <- state.do(valid_combos(design, patterns))
    state.return(acc + res)
  })
  |> cache.run
}
