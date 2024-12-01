import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn part1(input: String) -> Int {
  input
  |> string.trim_end
  |> string.split("\n")
  |> list.map(fn(l) { l |> string.split(" ") |> list.filter_map(int.parse) })
  |> list.transpose
  |> list.map(list.sort(_, int.compare))
  |> list.transpose
  |> list.fold(0, fn(sum, l) {
    let assert [a, b] = l
    int.absolute_value(a - b) + sum
  })
}

pub fn part2(input: String) -> Int {
  let assert [a, b] =
    input
    |> string.trim_end
    |> string.split("\n")
    |> list.map(fn(l) { l |> string.split(" ") |> list.filter_map(int.parse) })
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
