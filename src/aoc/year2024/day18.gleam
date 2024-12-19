import aoc/util/parser.{type Parser}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/order.{type Order}
import gleam/result
import gleam/set.{type Set}
import gleam/yielder.{type Yielder}
import gleamy/priority_queue.{type Queue} as pq
import party

type Coord =
  #(Int, Int)

type Grid =
  Dict(Coord, String)

type Node =
  #(Int, Coord)

fn order(a: Node, b: Node) -> Order {
  int.compare(a.0, b.0)
}

fn make_grid(size: Int, bytes: List(Coord)) -> Grid {
  let grid =
    0
    |> list.range(size)
    |> list.flat_map(fn(x) {
      0
      |> list.range(size)
      |> list.map(fn(y) { #(#(x, y), ".") })
    })
    |> dict.from_list

  list.fold(bytes, grid, fn(g, c) { dict.insert(g, c, "#") })
}

fn coord_p() -> Parser(Coord) {
  use a <- party.do(parser.int())
  use <- party.drop(party.string(","))
  use b <- party.map(parser.int())

  #(a, b)
}

fn input_p() -> Parser(List(Coord)) {
  party.sep1(coord_p(), party.string("\n"))
}

fn neighbors(grid: Grid, seen: Set(Coord), coord: Coord) -> List(Coord) {
  let #(x, y) = coord
  [#(x + 1, y), #(x - 1, y), #(x, y + 1), #(x, y - 1)]
  |> list.filter(fn(c) {
    dict.get(grid, c) == Ok(".") && !set.contains(seen, c)
  })
}

fn steps(
  grid: Grid,
  q: Queue(Node),
  goal: Coord,
  seen: Set(Coord),
) -> Result(Int, Nil) {
  use #(#(score, coord), q) <- result.try(pq.pop(q))

  case coord == goal, set.contains(seen, coord) {
    True, _ -> Ok(score)
    False, True -> steps(grid, q, goal, seen)
    False, False -> {
      let seen = set.insert(seen, coord)
      let q =
        grid
        |> neighbors(seen, coord)
        |> list.map(fn(c) { #(score + 1, c) })
        |> list.fold(q, pq.push)

      steps(grid, q, goal, seen)
    }
  }
}

fn timeline(grid: Grid, bytes: List(Coord)) -> Yielder(#(Coord, Grid)) {
  case bytes {
    [] -> yielder.empty()
    [h, ..t] -> {
      let grid = dict.insert(grid, h, "#")
      use <- yielder.yield(#(h, grid))
      timeline(grid, t)
    }
  }
}

pub fn part1(input: String, size: Int, n: Int) -> Int {
  let bytes = input |> parser.go(input_p()) |> list.take(n)
  let grid = make_grid(size, bytes)
  let q = pq.from_list([#(0, #(0, 0))], order)

  grid
  |> steps(q, #(size, size), set.new())
  |> result.unwrap(-1)
}

pub fn part2(input: String, size: Int) -> String {
  let bytes = parser.go(input, input_p())
  let grid = make_grid(size, [])
  let q = pq.from_list([#(0, #(0, 0))], order)
  let goal = #(size, size)

  grid
  |> timeline(bytes)
  |> yielder.find_map(fn(p) {
    let #(#(x, y), grid) = p
    case steps(grid, q, goal, set.new()) {
      Error(Nil) -> Ok(int.to_string(x) <> "," <> int.to_string(y))
      _ -> Error(Nil)
    }
  })
  |> result.unwrap("")
}
