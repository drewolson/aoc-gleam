import aoc/util/li
import aoc/util/str
import gleam/int
import gleam/list
import gleam/result
import gleam/string

fn pair_diffs(l: List(Int)) -> List(Int) {
  l |> list.zip(list.drop(l, 1)) |> list.map(fn(p) { p.1 - p.0 })
}

fn next_val(l: List(Int)) -> Int {
  case list.all(l, fn(n) { n == 0 }) {
    True -> 0
    False -> {
      let next = l |> pair_diffs |> next_val
      next + { l |> list.last |> result.unwrap(0) }
    }
  }
}

pub fn part1(input: String) -> Int {
  input
  |> str.lines
  |> list.map(fn(l) {
    l |> string.split(on: " ") |> list.filter_map(int.parse) |> next_val
  })
  |> li.sum
}

pub fn part2(input: String) -> Int {
  input
  |> str.lines
  |> list.map(fn(l) {
    l
    |> string.split(on: " ")
    |> list.filter_map(int.parse)
    |> list.reverse
    |> next_val
  })
  |> li.sum
}
