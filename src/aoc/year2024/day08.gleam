import aoc/util/str
import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{None, Some}
import gleam/set.{type Set}
import gleam/string

type Coord =
  #(Int, Int)

type Grid =
  Dict(Coord, String)

type Nodes =
  Dict(String, List(Coord))

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

fn make_nodes(grid: Grid) -> Nodes {
  grid
  |> dict.to_list
  |> list.fold(dict.new(), fn(d, p) {
    let #(k, v) = p
    case v {
      "." -> d
      _ ->
        dict.upsert(d, v, fn(o) {
          case o {
            None -> [k]
            Some(l) -> [k, ..l]
          }
        })
    }
  })
}

fn parse(input: String) -> #(Grid, Nodes) {
  let grid = make_grid(input)
  let nodes = make_nodes(grid)

  #(grid, nodes)
}

fn pairs(l: List(a)) -> List(#(a, a)) {
  case l {
    [] -> []
    [_] -> []
    [a, ..t] ->
      t
      |> list.map(fn(b) { #(a, b) })
      |> list.append(pairs(t))
  }
}

fn next(acc: Set(Coord), grid: Grid, c: Coord, dx: Int, dy: Int) -> Set(Coord) {
  let new = #(c.0 + dx, c.1 + dy)

  case dict.get(grid, new) {
    Error(_) -> acc
    Ok(_) -> set.insert(acc, new)
  }
}

fn search(acc: Set(Coord), grid: Grid, c: Coord, dx: Int, dy: Int) -> Set(Coord) {
  case dict.get(grid, c) {
    Error(_) -> acc
    Ok(_) -> search(set.insert(acc, c), grid, #(c.0 + dx, c.1 + dy), dx, dy)
  }
}

fn antinodes(
  f: fn(Set(Coord), Grid, Coord, Int, Int) -> Set(Coord),
  acc: Set(Coord),
  grid: Grid,
  nodes: List(Coord),
) -> Set(Coord) {
  nodes
  |> pairs
  |> list.fold(acc, fn(s, p) {
    let #(a, b) = p
    let dx = b.0 - a.0
    let dy = b.1 - a.1

    s
    |> f(grid, b, dx, dy)
    |> f(grid, a, -dx, -dy)
  })
}

pub fn part1(input: String) -> Int {
  let #(grid, nodes) = parse(input)

  nodes
  |> dict.values
  |> list.fold(set.new(), fn(s, ns) { antinodes(next, s, grid, ns) })
  |> set.size
}

pub fn part2(input: String) -> Int {
  let #(grid, nodes) = parse(input)

  nodes
  |> dict.values
  |> list.fold(set.new(), fn(s, ns) { antinodes(search, s, grid, ns) })
  |> set.size
}
