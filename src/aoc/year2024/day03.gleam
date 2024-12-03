import aoc/util/re
import gleam/int
import gleam/list
import gleam/option
import gleam/regexp.{type Match, type Regexp}
import gleam/result
import gleam/string

fn mul_re() -> Regexp {
  re.from_string("mul\\(([0-9]{1,3}),([0-9]{1,3})\\)")
}

fn mul(m: Match) -> Int {
  m.submatches
  |> list.filter_map(fn(s) {
    s |> option.to_result(Nil) |> result.then(int.parse)
  })
  |> list.fold(1, fn(p, n) { p * n })
}

pub fn part1(input: String) -> Int {
  mul_re()
  |> regexp.scan(input)
  |> list.fold(0, fn(s, m) { s + mul(m) })
}

pub fn part2(input: String) -> Int {
  { "do()" <> input }
  |> string.split("don't()")
  |> list.fold(0, fn(sum, s) {
    case string.split_once(s, "do()") {
      Error(_) -> sum
      Ok(#(_, t)) -> sum + part1(t)
    }
  })
}
