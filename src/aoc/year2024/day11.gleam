import aoc/util/state.{type State}
import aoc/util/str
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string

type Cache =
  Dict(#(Int, Int), Int)

fn split(stone: Int) -> List(Int) {
  let ds = int.digits(stone, 10) |> result.unwrap([])
  let l = list.length(ds)

  case stone, int.is_even(l) {
    0, _ -> [1]
    _, True -> {
      let #(a, b) = list.split(ds, l / 2)
      [a, b]
      |> list.map(fn(ns) { list.drop_while(ns, fn(d) { d == 0 }) })
      |> list.filter_map(int.undigits(_, 10))
    }
    _, False -> [stone * 2024]
  }
}

fn expand(stone: Int, n: Int) -> State(Cache, Int) {
  use cache <- state.do(state.get())

  case dict.get(cache, #(stone, n)), n {
    Ok(n), _ -> state.return(n)
    _, 0 -> state.return(1)
    _, _ -> {
      use res <- state.do(
        stone
        |> split
        |> list.fold(state.return(0), fn(ssum, s) {
          use sum <- state.do(ssum)
          use next <- state.do(expand(s, n - 1))
          state.return(sum + next)
        }),
      )
      use _ <- state.do(state.modify(dict.insert(_, #(stone, n), res)))
      state.return(res)
    }
  }
}

fn blink(stones: List(Int), n: Int) -> Int {
  stones
  |> list.fold(state.return(0), fn(ssum, stone) {
    use sum <- state.do(ssum)
    use next <- state.do(expand(stone, n))
    state.return(sum + next)
  })
  |> state.eval(dict.new())
}

pub fn part1(input: String) -> Int {
  input
  |> string.trim
  |> str.nums
  |> blink(25)
}

pub fn part2(input: String) -> Int {
  input
  |> string.trim
  |> str.nums
  |> blink(75)
}
