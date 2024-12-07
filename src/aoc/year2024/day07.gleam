import aoc/util/parser.{type Parser}
import gleam/int
import gleam/list
import gleam/yielder.{type Yielder}
import party

type Op =
  #(Int, List(Int))

fn op_p() -> Parser(Op) {
  use goal <- party.do(parser.int())
  use <- parser.drop(party.string(": "))
  use l <- party.map(party.sep1(parser.int(), party.string(" ")))

  #(goal, l)
}

fn ops_p() -> Parser(List(Op)) {
  party.sep1(op_p(), party.string("\n"))
}

fn add(a: Int, b: Int) -> Int {
  a + b
}

fn mul(a: Int, b: Int) -> Int {
  a * b
}

fn combine(a: Int, b: Int) -> Int {
  let assert Ok(c) = { int.to_string(b) <> int.to_string(a) } |> int.parse
  c
}

fn results(l: List(Int), ops: List(fn(Int, Int) -> Int)) -> Yielder(Int) {
  case l {
    [] -> yielder.empty()
    [a] -> yielder.single(a)
    [h, ..t] -> {
      use a <- yielder.flat_map(results(t, ops))
      ops
      |> list.map(fn(op) { op(h, a) })
      |> yielder.from_list
    }
  }
}

fn valid(op: Op, ops: List(fn(Int, Int) -> Int)) -> Bool {
  op.1
  |> list.reverse
  |> results(ops)
  |> yielder.any(fn(r) { r == op.0 })
}

pub fn part1(input: String) -> Int {
  input
  |> parser.go(ops_p())
  |> list.filter(valid(_, [add, mul]))
  |> list.fold(0, fn(s, op) { s + op.0 })
}

pub fn part2(input: String) -> Int {
  input
  |> parser.go(ops_p())
  |> list.filter(valid(_, [add, mul, combine]))
  |> list.fold(0, fn(s, op) { s + op.0 })
}
