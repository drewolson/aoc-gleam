import aoc/util/cache.{type Cache}
import aoc/util/ints
import aoc/util/state
import aoc/util/str
import gleam/int
import gleam/list
import gleam/result

fn split(stone: Int) -> List(Int) {
  let ds = ints.digits(stone, 10) |> result.unwrap([])
  let l = list.length(ds)

  case stone, int.is_even(l) {
    0, _ -> [1]
    _, True -> {
      let #(a, b) = list.split(ds, l / 2)
      [a, b]
      |> list.map(fn(ns) { list.drop_while(ns, fn(d) { d == 0 }) })
      |> list.filter_map(ints.undigits(_, 10))
    }
    _, False -> [stone * 2024]
  }
}

fn expand(stone: Int, n: Int) -> Cache(#(Int, Int), Int) {
  use <- cache.get_or(#(stone, n))

  case n {
    0 -> state.return(1)
    _ -> {
      stone
      |> split
      |> list.fold(state.return(0), fn(ssum, s) {
        use sum <- state.do(ssum)
        use next <- state.do(expand(s, n - 1))
        state.return(sum + next)
      })
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
  |> cache.run
}

pub fn part1(input: String) -> Int {
  input
  |> str.nums
  |> blink(25)
}

pub fn part2(input: String) -> Int {
  input
  |> str.nums
  |> blink(75)
}
