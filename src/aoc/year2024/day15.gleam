import aoc/util/str
import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string

type Coord =
  #(Int, Int)

type Grid =
  Dict(Coord, String)

type Dir {
  Up
  Down
  Left
  Right
}

fn make_grid(str: String, f: fn(String) -> List(String)) -> Grid {
  str
  |> str.lines
  |> list.index_map(fn(l, y) {
    l
    |> string.to_graphemes
    |> list.flat_map(f)
    |> list.index_map(fn(c, x) { #(#(x, y), c) })
  })
  |> list.flatten
  |> dict.from_list
}

fn parse(input: String, f: fn(String) -> List(String)) -> #(Grid, List(Dir)) {
  let assert Ok(#(a, b)) = string.split_once(input, "\n\n")
  let dirs =
    b
    |> str.lines
    |> list.flat_map(fn(l) { string.to_graphemes(l) })
    |> list.filter_map(fn(c) {
      case c {
        "^" -> Ok(Up)
        "v" -> Ok(Down)
        "<" -> Ok(Left)
        ">" -> Ok(Right)
        _ -> Error(Nil)
      }
    })
  #(make_grid(a, f), dirs)
}

fn find_robot(grid: Grid) -> Coord {
  grid
  |> dict.to_list
  |> list.find(fn(p) { p.1 == "@" })
  |> result.map(fn(p) { p.0 })
  |> result.unwrap(#(0, 0))
}

fn next(grid: Grid, coord: Coord, dir: Dir) -> Result(#(Coord, String), Nil) {
  let #(x, y) = coord
  let next_c = case dir {
    Up -> #(x, y - 1)
    Down -> #(x, y + 1)
    Left -> #(x - 1, y)
    Right -> #(x + 1, y)
  }
  use v <- result.map(dict.get(grid, next_c))
  #(next_c, v)
}

fn push(
  grid: Grid,
  coord: Coord,
  v: String,
  rep: String,
  dir: Dir,
) -> Result(Grid, Nil) {
  let grid = dict.insert(grid, coord, rep)
  use #(next_c, next_v) <- result.try(next(grid, coord, dir))
  let grid = dict.insert(grid, next_c, v)
  case next_v {
    "." -> Ok(grid)
    "O" -> push(grid, next_c, next_v, v, dir)
    "[" | "]" if dir == Left || dir == Right ->
      push(grid, next_c, next_v, v, dir)
    "[" -> {
      use grid <- result.try(push(grid, next_c, next_v, v, dir))
      push(grid, #(next_c.0 + 1, next_c.1), "]", ".", dir)
    }
    "]" -> {
      use grid <- result.try(push(grid, next_c, next_v, v, dir))
      push(grid, #(next_c.0 - 1, next_c.1), "[", ".", dir)
    }
    _ -> Error(Nil)
  }
}

fn expand(c: String) -> List(String) {
  case c {
    "#" -> ["#", "#"]
    "O" -> ["[", "]"]
    "@" -> ["@", "."]
    _ -> [".", "."]
  }
}

pub fn solve(input: String, block: String, f: fn(String) -> List(String)) -> Int {
  let #(grid, dirs) = parse(input, f)
  let robot = find_robot(grid)
  let #(grid, _) =
    list.fold(dirs, #(grid, robot), fn(acc, dir) {
      let #(grid, robot) = acc
      let res = {
        use next_g <- result.try(push(grid, robot, "@", ".", dir))
        use #(next_r, _) <- result.map(next(grid, robot, dir))
        #(next_g, next_r)
      }
      result.unwrap(res, acc)
    })
  grid
  |> dict.filter(fn(_k, v) { v == block })
  |> dict.keys
  |> list.fold(0, fn(s, k) { s + k.0 + 100 * k.1 })
}

pub fn part1(input: String) -> Int {
  solve(input, "O", fn(c) { [c] })
}

pub fn part2(input: String) -> Int {
  solve(input, "[", expand)
}
