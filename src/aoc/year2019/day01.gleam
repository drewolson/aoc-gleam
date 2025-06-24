import gleam/int
import gleam/list
import gleam/string

fn fuel(m: Int) -> Int {
  m / 3 - 2
}

fn rec_fuel(m: Int, f: Int) -> Int {
  let next = fuel(m)

  case next <= 0 {
    True -> f
    False -> {
      rec_fuel(next, f + next)
    }
  }
}

pub fn part1(input: String) -> Int {
  input
  |> string.trim_end
  |> string.split("\n")
  |> list.filter_map(int.parse)
  |> list.fold(0, fn(s, m) { s + fuel(m) })
}

pub fn part2(input: String) -> Int {
  input
  |> string.trim_end
  |> string.split("\n")
  |> list.filter_map(int.parse)
  |> list.fold(0, fn(s, m) { s + rec_fuel(m, 0) })
}
