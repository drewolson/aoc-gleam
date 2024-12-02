import aoc/util/str
import gleam/list
import gleam/yielder.{type Yielder}

fn safe(l: List(Int)) -> Bool {
  let diffs =
    l
    |> list.zip(list.drop(l, 1))
    |> list.map(fn(p) { p.1 - p.0 })

  list.all(diffs, fn(d) { d > 0 && d <= 3 })
  || list.all(diffs, fn(d) { d >= -3 && d < 0 })
}

fn perms(l: List(Int)) -> Yielder(List(Int)) {
  case l {
    [] -> yielder.single([])
    [h, ..t] -> {
      use <- yielder.yield(t)
      t |> perms |> yielder.map(fn(l) { [h, ..l] })
    }
  }
}

pub fn part1(input: String) -> Int {
  input
  |> str.lines
  |> list.map(str.nums)
  |> list.count(safe)
}

pub fn part2(input: String) -> Int {
  input
  |> str.lines
  |> list.map(str.nums)
  |> list.count(fn(r) { r |> perms |> yielder.any(safe) })
}
