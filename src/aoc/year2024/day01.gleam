import aoc/util/str
import gleam/dict
import gleam/int
import gleam/list
import gleam/result

pub fn part1(input: String) -> Int {
  let assert [a, b] =
    input
    |> str.lines
    |> list.map(str.nums)
    |> list.transpose
    |> list.map(list.sort(_, int.compare))

  a
  |> list.zip(b)
  |> list.fold(0, fn(sum, p) { int.absolute_value(p.0 - p.1) + sum })
}

pub fn part2(input: String) -> Int {
  let assert [a, b] =
    input
    |> str.lines
    |> list.map(str.nums)
    |> list.transpose

  let map = list.group(b, fn(a) { a })

  list.fold(a, 0, fn(sum, i) {
    let mul =
      map
      |> dict.get(i)
      |> result.map(list.length)
      |> result.unwrap(0)

    sum + { i * mul }
  })
}
