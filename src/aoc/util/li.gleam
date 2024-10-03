import gleam/list

pub fn sum(list: List(Int)) -> Int {
  list.fold(list, 0, fn(sum, i) { sum + i })
}
