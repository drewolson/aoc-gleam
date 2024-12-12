import gleam/dict.{type Dict}
import gleam/function
import gleam/list

pub fn sum(list: List(Int)) -> Int {
  list.fold(list, 0, fn(sum, i) { sum + i })
}

pub fn counts(list: List(a)) -> Dict(a, Int) {
  list
  |> list.group(function.identity)
  |> dict.map_values(fn(_, v) { list.length(v) })
}
