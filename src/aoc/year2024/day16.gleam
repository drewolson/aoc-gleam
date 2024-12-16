import aoc/util/str
import gleam/dict.{type Dict}
import gleam/int
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
  seen: Set(#(Coord, Dir)),
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
    !set.contains(seen, #(node.1, node.2))
    && case dict.get(grid, node.1) {
      Ok(v) -> v != "#"
      _ -> False
    }
  })
}

fn merge_nodes_aux(
  q: Queue(Node),
  goal: Coord,
  dir: Dir,
  score: Int,
  nonmatch: List(Node),
  path: Set(Coord),
) -> #(Queue(Node), Node) {
  case pq.pop(q) {
    Ok(#(#(s, coord, d, p) as node, q)) if s == score -> {
      case coord == goal && d == dir {
        False -> merge_nodes_aux(q, goal, dir, score, [node, ..nonmatch], path)
        True ->
          merge_nodes_aux(q, goal, dir, score, nonmatch, set.union(path, p))
      }
    }
    _ -> {
      let q = list.fold(nonmatch, q, pq.push)
      let node = #(score, goal, dir, path)
      #(q, node)
    }
  }
}

fn merge_nodes(
  q: Queue(Node),
  goal: Coord,
  dir: Dir,
  score: Int,
) -> #(Queue(Node), Node) {
  merge_nodes_aux(q, goal, dir, score, [], set.new())
}

fn search(
  q: Queue(Node),
  seen: Set(#(Coord, Dir)),
  grid: Grid,
  goal: Coord,
) -> #(Int, Set(Coord)) {
  case pq.pop(q) {
    Error(_) -> #(0, set.new())
    Ok(#(#(score, coord, dir, _), _)) if coord == goal -> {
      let #(_, node) = merge_nodes(q, coord, dir, score)
      #(score, node.3)
    }
    Ok(#(#(score, coord, dir, _), nq)) -> {
      case set.contains(seen, #(coord, dir)) {
        True -> search(nq, seen, grid, goal)
        False -> {
          let #(q, node) = merge_nodes(q, coord, dir, score)
          let seen = set.insert(seen, #(coord, dir))
          let #(_, coord, dir, path) = node
          neighbors(coord, seen, grid, dir)
          |> list.map(fn(node) {
            #(node.0 + score, node.1, node.2, set.insert(path, node.1))
          })
          |> list.fold(q, pq.push)
          |> search(seen, grid, goal)
        }
      }
    }
  }
}

pub fn solve(input: String) -> #(Int, Set(Coord)) {
  let grid = make_grid(input)
  let start = find_coord(grid, "S")
  let goal = find_coord(grid, "E")
  let q = pq.from_list([#(0, start, East, set.from_list([start]))], order)
  search(q, set.new(), grid, goal)
}

pub fn part1(input: String) -> Int {
  solve(input).0
}

pub fn part2(input: String) -> Int {
  solve(input).1 |> set.size
}
