import aoc/util/li
import aoc/util/str
import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/list
import gleam/result
import gleam/string

type Coord =
  #(Int, Int)

type Grid =
  Dict(Coord, Int)

fn make_grid(str: String) -> Grid {
  str
  |> str.lines
  |> list.index_map(fn(l, y) {
    l
    |> string.to_graphemes
    |> list.filter_map(int.parse)
    |> list.index_map(fn(c, x) { #(#(x, y), c) })
  })
  |> list.flatten
  |> dict.from_list
}

fn find_heads(grid: Grid) -> List(Coord) {
  grid
  |> dict.to_list
  |> list.filter_map(fn(p) {
    case p.1 {
      0 -> Ok(p.0)
      _ -> Error(Nil)
    }
  })
}

fn neighbors(curr: Coord, grid: Grid) -> List(Coord) {
  let #(x, y) = curr

  [#(x + 1, y), #(x - 1, y), #(x, y + 1), #(x, y - 1)]
  |> list.filter(fn(c) { grid |> dict.get(c) |> result.is_ok })
}

fn is_valid(c: Coord, grid: Grid, score: Int) -> Bool {
  dict.get(grid, c) == Ok(score + 1)
}

fn score(
  grid: Grid,
  f: fn(List(Coord)) -> List(Coord),
  curr: List(Coord),
  acc: Int,
) -> Int {
  case list.is_empty(curr) {
    True -> acc
    False -> {
      let acc = acc + list.count(curr, fn(c) { dict.get(grid, c) == Ok(9) })

      let next =
        curr
        |> list.filter_map(fn(c) {
          use v <- result.map(dict.get(grid, c))
          #(c, v)
        })
        |> list.flat_map(fn(p) {
          p.0
          |> neighbors(grid)
          |> list.filter(is_valid(_, grid, p.1))
        })
        |> f

      score(grid, f, next, acc)
    }
  }
}

fn solve(input: String, f: fn(List(Coord)) -> List(Coord)) -> Int {
  let grid = make_grid(input)
  let heads = find_heads(grid)

  heads
  |> list.map(fn(head) { score(grid, f, [head], 0) })
  |> li.sum
}

pub fn part1(input: String) -> Int {
  solve(input, list.unique)
}

pub fn part2(input: String) -> Int {
  solve(input, function.identity)
}
