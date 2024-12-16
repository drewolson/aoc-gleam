import aoc/util/str
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/order.{type Order}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleamy/priority_queue.{type Queue} as pq

type Coord =
  #(Int, Int)

type Grid =
  Dict(Coord, String)

type Dir {
  North
  South
  East
  West
}

type Node =
  #(Int, Coord, Dir, Set(Coord))

fn make_grid(str: String) -> Grid {
  str
  |> str.lines
  |> list.index_map(fn(l, y) {
    l
    |> string.to_graphemes
    |> list.index_map(fn(c, x) { #(#(x, y), c) })
  })
  |> list.flatten
  |> dict.from_list
}

fn find_coord(grid: Grid, val: String) -> Coord {
  let assert Ok(coord) =
    grid
    |> dict.to_list
    |> list.find(fn(p) { p.1 == val })
    |> result.map(fn(p) { p.0 })

  coord
}

fn order(a: Node, b: Node) -> Order {
  let #(a_score, _, _, _) = a
  let #(b_score, _, _, _) = b
  int.compare(a_score, b_score)
}

fn neighbors(
  coord: Coord,
  seen: Set(Coord),
  grid: Grid,
  dir: Dir,
) -> List(#(Int, Coord, Dir)) {
  let #(x, y) = coord
  let candidates = case dir {
    North -> [
      #(1, #(x, y - 1), North),
      #(1001, #(x - 1, y), West),
      #(1001, #(x + 1, y), East),
    ]
    South -> [
      #(1, #(x, y + 1), South),
      #(1001, #(x - 1, y), West),
      #(1001, #(x + 1, y), East),
    ]
    East -> [
      #(1, #(x + 1, y), East),
      #(1001, #(x, y + 1), South),
      #(1001, #(x, y - 1), North),
    ]
    West -> [
      #(1, #(x - 1, y), West),
      #(1001, #(x, y + 1), South),
      #(1001, #(x, y - 1), North),
    ]
  }

  candidates
  |> list.filter(fn(node) {
    !set.contains(seen, node.1)
    && case dict.get(grid, node.1) {
      Ok(v) -> v != "#"
      _ -> False
    }
  })
}

fn all_paths(
  q: Queue(Node),
  goal: Coord,
  score: Int,
  acc: List(#(Int, Set(Coord))),
) -> List(#(Int, Set(Coord))) {
  case pq.pop(q) {
    Ok(#(#(s, coord, _, path), q)) if s == score -> {
      case coord == goal {
        False -> all_paths(q, goal, score, acc)
        True -> all_paths(q, goal, score, [#(s, path), ..acc])
      }
    }
    _ -> acc
  }
}

fn search(
  q: Queue(Node),
  seen: Set(Coord),
  grid: Grid,
  goal: Coord,
) -> List(#(Int, Set(Coord))) {
  case pq.pop(q) {
    Error(_) -> []
    Ok(#(#(score, coord, _, _), _)) if coord == goal ->
      all_paths(q, goal, score, [])
    Ok(#(#(score, coord, dir, path), q)) -> {
      case set.contains(seen, coord) {
        True -> search(q, seen, grid, goal)
        False -> {
          let seen = set.insert(seen, coord)
          coord
          |> neighbors(seen, grid, dir)
          |> list.map(fn(node) {
            #(node.0 + score, node.1, node.2, set.insert(path, node.1))
          })
          |> list.fold(q, fn(q, node) { pq.push(q, node) })
          |> search(set.insert(seen, coord), grid, goal)
        }
      }
    }
  }
}

pub fn part1(input: String) -> Int {
  let grid = make_grid(input)
  let start = find_coord(grid, "S")
  let goal = find_coord(grid, "E")
  let q = pq.from_list([#(0, start, East, set.from_list([start]))], order)
  let assert Ok(#(score, _)) =
    q
    |> search(set.new(), grid, goal)
    |> list.first
  score
}

pub fn part2(input: String) -> Int {
  let grid = make_grid(input)
  let start = find_coord(grid, "S")
  let goal = find_coord(grid, "E")
  let q = pq.from_list([#(0, start, East, set.from_list([start]))], order)

  q
  |> search(set.new(), grid, goal)
  |> io.debug
  |> list.map(fn(p) { p.1 })
  |> list.fold(set.new(), fn(acc, s) { set.union(acc, s) })
  |> set.size
}
