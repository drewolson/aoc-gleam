import aoc/util/str
import gleam/dict.{type Dict}
import gleam/list
import gleam/otp/task
import gleam/result
import gleam/set.{type Set}
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

type Guard =
  #(Coord, Dir)

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

fn find_guard(grid: Grid) -> Coord {
  grid
  |> dict.to_list
  |> list.find_map(fn(p) {
    let #(k, v) = p
    case v == "^" {
      True -> Ok(k)
      False -> Error(Nil)
    }
  })
  |> result.unwrap(#(0, 0))
}

fn next_pos(guard: Guard, grid: Grid) -> Result(Guard, Nil) {
  let #(#(x, y), dir) = guard

  let coord = case dir {
    Up -> #(x, y - 1)
    Down -> #(x, y + 1)
    Left -> #(x - 1, y)
    Right -> #(x + 1, y)
  }

  use next <- result.map(dict.get(grid, coord))

  let new_dir = case dir {
    Up -> Right
    Right -> Down
    Down -> Left
    Left -> Up
  }

  case next {
    "#" -> #(#(x, y), new_dir)
    _ -> #(coord, dir)
  }
}

fn move(guard: Guard, grid: Grid, seen: Set(Coord)) -> Set(Coord) {
  case next_pos(guard, grid) {
    Error(_) -> seen
    Ok(new_guard) -> move(new_guard, grid, set.insert(seen, new_guard.0))
  }
}

fn is_loop(grid: Grid, guard: Guard, seen: Set(Guard)) -> Bool {
  case next_pos(guard, grid) {
    Error(_) -> False
    Ok(new_guard) -> {
      case set.contains(seen, new_guard) {
        True -> True
        False -> is_loop(grid, new_guard, set.insert(seen, new_guard))
      }
    }
  }
}

pub fn part1(input: String) -> Int {
  let grid = parse(input)
  let pos = find_guard(grid)

  #(pos, Up)
  |> move(grid, set.from_list([pos]))
  |> set.size
}

pub fn part2(input: String) -> Int {
  let grid = parse(input)
  let pos = find_guard(grid)

  grid
  |> dict.filter(fn(_, v) { v == "." })
  |> dict.keys
  |> list.map(fn(c) {
    task.async(fn() {
      grid
      |> dict.insert(c, "#")
      |> is_loop(#(pos, Up), set.from_list([#(pos, Up)]))
    })
  })
  |> list.count(task.await_forever)
}
