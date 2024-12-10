import aoc/util/li
import aoc/util/str
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
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

fn score(grid: Grid, curr: Set(Coord), acc: Int) -> Int {
  case set.is_empty(curr) {
    True -> acc
    False -> {
      let acc =
        acc
        + {
          curr
          |> set.to_list
          |> list.count(fn(c) { dict.get(grid, c) == Ok(9) })
        }
      let next =
        curr
        |> set.to_list
        |> list.filter_map(fn(c) {
          use v <- result.map(dict.get(grid, c))
          #(c, v)
        })
        |> list.flat_map(fn(p) {
          let #(c, v) = p
          c
          |> neighbors(grid)
          |> list.filter(is_valid(_, grid, v))
        })
        |> set.from_list
      score(grid, next, acc)
    }
  }
}

fn score2(grid: Grid, curr: Coord) -> Int {
  case dict.get(grid, curr) {
    Error(_) -> 0
    Ok(9) -> 1
    Ok(s) -> {
      let next =
        curr
        |> neighbors(grid)
        |> list.filter(is_valid(_, grid, s))

      list.fold(next, 0, fn(s, n) { s + score2(grid, n) })
    }
  }
}

pub fn part1(input: String) -> Int {
  let grid = make_grid(input)
  let heads = find_heads(grid)

  heads
  |> list.map(fn(head) { score(grid, set.from_list([head]), 0) })
  |> li.sum
}

pub fn part2(input: String) -> Int {
  let grid = make_grid(input)
  let heads = find_heads(grid)

  heads
  |> list.map(fn(head) { score2(grid, head) })
  |> li.sum
}
