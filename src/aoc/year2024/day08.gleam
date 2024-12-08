import aoc/util/str
import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set
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

fn antinodes(nodes: List(Coord)) -> List(Coord) {
  nodes
  |> pairs
  |> list.flat_map(fn(p) {
    let #(a, b) = p
    let #(a1, a2) = a
    let #(b1, b2) = b

    [
      #({ b1 - a1 } + b1, { b2 - a2 } + b2),
      #({ a1 - b1 } + a1, { a2 - b2 } + a2),
    ]
  })
}

fn search(grid: Grid, c: Coord, dx: Int, dy: Int, acc: List(Coord)) {
  case dict.get(grid, c) {
    Error(_) -> acc
    Ok(_) -> search(grid, #(c.0 + dx, c.1 + dy), dx, dy, [c, ..acc])
  }
}

fn antinodes2(grid: Grid, nodes: List(Coord)) -> List(Coord) {
  nodes
  |> pairs
  |> list.flat_map(fn(p) {
    let #(a, b) = p
    let dx = b.0 - a.0
    let dy = b.1 - a.1
    list.append(search(grid, b, dx, dy, []), search(grid, a, -dx, -dy, []))
  })
}

pub fn part1(input: String) -> Int {
  let #(grid, nodes) = parse(input)
  nodes
  |> dict.values
  |> list.flat_map(antinodes)
  |> list.unique
  |> list.count(fn(an) { grid |> dict.get(an) |> result.is_ok })
}

pub fn part2(input: String) -> Int {
  let #(grid, nodes) = parse(input)

  nodes
  |> dict.values
  |> list.fold(set.new(), fn(s, ns) {
    grid |> antinodes2(ns) |> set.from_list |> set.union(s)
  })
  |> set.size
}
