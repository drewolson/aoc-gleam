import aoc/util/str
import gleam/int
import gleam/list
import gleam/string

fn safe(l: List(Int)) -> Bool {
  let diffs =
    l
    |> list.zip(list.drop(l, 1))
    |> list.map(fn(p) { p.1 - p.0 })

  list.all(diffs, fn(d) { d > 0 && d <= 3 })
  || list.all(diffs, fn(d) { d >= -3 && d < 0 })
}

fn perms(l: List(Int)) -> List(List(Int)) {
  case l {
    [] -> [[]]
    [h, ..t] -> t |> perms |> list.map(fn(l) { [h, ..l] }) |> list.prepend(t)
  }
}

pub fn part1(input: String) -> Int {
  input
  |> str.lines
  |> list.map(fn(l) { l |> string.split(" ") |> list.filter_map(int.parse) })
  |> list.count(safe)
}

pub fn part2(input: String) -> Int {
  input
  |> str.lines
  |> list.map(fn(l) { l |> string.split(" ") |> list.filter_map(int.parse) })
  |> list.count(fn(r) { r |> perms |> list.any(safe) })
}
