import aoc/util/str
import gleam/dict.{type Dict}
import gleam/list
import gleam/string

type Coord =
  #(Int, Int)

type Grid =
  Dict(Coord, String)

fn parse(input: String) -> Grid {
  input
  |> str.lines
  |> list.index_map(fn(l, y) {
    l
    |> string.to_graphemes
    |> list.index_map(fn(c, x) { #(#(x, y), c) })
  })
  |> list.flatten
  |> dict.from_list
}

fn find_keys(grid: Grid, val: String) -> List(Coord) {
  grid
  |> dict.filter(fn(_k, v) { v == val })
  |> dict.keys
}

fn words(grid: Grid, c: Coord) -> List(String) {
  let #(x, y) = c

  list.range(1, 3)
  |> list.map(fn(i) {
    [
      #(x + i, y),
      #(x - i, y),
      #(x, y + i),
      #(x, y - i),
      #(x + i, y + i),
      #(x + i, y - i),
      #(x - i, y + i),
      #(x - i, y - i),
    ]
  })
  |> list.transpose
  |> list.map(fn(ray) {
    ray
    |> list.filter_map(dict.get(grid, _))
    |> string.join("")
  })
}

fn xs(grid: Grid, c: Coord) -> String {
  let #(x, y) = c
  let a = [#(x - 1, y - 1), #(x + 1, y + 1)]
  let b = [#(x - 1, y + 1), #(x + 1, y - 1)]

  [a, b]
  |> list.flat_map(fn(l) {
    l |> list.filter_map(dict.get(grid, _)) |> list.sort(string.compare)
  })
  |> string.join("")
}

pub fn part1(input: String) -> Int {
  let grid = parse(input)
  let starts = find_keys(grid, "X")
  starts
  |> list.flat_map(words(grid, _))
  |> list.count(fn(w) { w == "MAS" })
}

pub fn part2(input: String) -> Int {
  let grid = parse(input)
  let starts = find_keys(grid, "A")
  starts
  |> list.map(xs(grid, _))
  |> list.count(fn(w) { w == "MSMS" })
}
