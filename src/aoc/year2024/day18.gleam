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
  let #(a_score, _) = a
  let #(b_score, _) = b
  int.compare(a_score, b_score)
}

fn make_grid(size: Int, bytes: List(Coord)) -> Grid {
  let grid =
    list.range(0, size)
    |> list.flat_map(fn(x) {
      list.range(0, size)
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

fn neighbors(grid: Grid, coord: Coord) -> List(Coord) {
  let #(x, y) = coord
  [#(x + 1, y), #(x - 1, y), #(x, y + 1), #(x, y - 1)]
  |> list.filter(fn(c) { dict.get(grid, c) == Ok(".") })
}

fn steps(grid: Grid, q: Queue(Node), goal: Coord, seen: Set(Coord)) -> Int {
  case pq.pop(q) {
    Error(_) -> -1
    Ok(#(#(score, coord), _)) if coord == goal -> score
    Ok(#(node, q)) -> {
      let #(score, coord) = node
      case set.contains(seen, coord) {
        True -> steps(grid, q, goal, seen)
        False -> {
          let seen = set.insert(seen, coord)
          let q =
            grid
            |> neighbors(coord)
            |> list.filter_map(fn(c) {
              case set.contains(seen, c) {
                True -> Error(Nil)
                False -> Ok(#(score + 1, c))
              }
            })
            |> list.fold(q, pq.push)

          steps(grid, q, goal, seen)
        }
      }
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

  steps(grid, q, #(size, size), set.new())
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
      -1 -> Ok(int.to_string(x) <> "," <> int.to_string(y))
      _ -> Error(Nil)
    }
  })
  |> result.unwrap("")
}
