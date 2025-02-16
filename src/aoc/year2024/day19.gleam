import aoc/util/cache.{type Cache}
import aoc/util/state
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
  use <- cache.get_or(design)

  case string.is_empty(design) {
    True -> state.return(1)
    False -> {
      state.fold(patterns, 0, fn(acc, pattern) {
        use res <- state.map(case string.starts_with(design, pattern) {
          False -> state.return(0)
          True ->
            valid_combos(
              string.drop_start(design, string.length(pattern)),
              patterns,
            )
        })

        acc + res
      })
    }
  }
}

pub fn part1(input: String) -> Int {
  let #(patterns, designs) = parse(input)

  designs
  |> state.fold(0, fn(acc, design) {
    use res <- state.map(valid_combos(design, patterns))
    case res > 0 {
      True -> acc + 1
      False -> acc
    }
  })
  |> cache.run
}

pub fn part2(input: String) -> Int {
  let #(patterns, designs) = parse(input)

  designs
  |> state.fold(0, fn(acc, design) {
    use res <- state.map(valid_combos(design, patterns))
    acc + res
  })
  |> cache.run
}
