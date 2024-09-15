import aoc/util/hashtbl.{type Hashtbl}
import aoc/util/str
import gleam/int
import gleam/list
import gleam/string

type Grid =
  List(List(String))

fn parse(input: String) -> Grid {
  input
  |> str.lines
  |> list.map(string.to_graphemes)
  |> rotate
}

fn rotate(grid: Grid) -> Grid {
  grid
  |> list.transpose
  |> list.map(list.reverse)
}

fn shift_rocks_aux(p: #(List(String), List(String)), rock: String) {
  case rock, p {
    "O", #(rocks, l) -> #(["O", ..rocks], l)
    ".", #(rocks, l) -> #(rocks, [".", ..l])
    "#", #(rocks, l) -> #([], list.append(["#", ..rocks], l))
    _, p -> p
  }
}

fn shift_rocks(l: List(String)) -> List(String) {
  let #(rocks, l) = list.fold(l, #([], []), shift_rocks_aux)
  rocks |> list.append(l) |> list.reverse
}

fn tilt(grid: Grid) -> Grid {
  list.map(grid, shift_rocks)
}

fn load(l: List(String)) -> Int {
  l
  |> list.index_map(fn(c, i) {
    case c {
      "O" -> i + 1
      _ -> 0
    }
  })
  |> list.fold(0, fn(a, b) { a + b })
}

fn cycle(grid: Grid) -> Grid {
  list.range(0, 3)
  |> list.fold(grid, fn(grid, _) { grid |> tilt |> rotate })
}

fn run_cycles(grid: Grid, cache: Hashtbl(Grid, Int), n: Int) -> Grid {
  case n {
    0 -> grid
    n -> {
      case hashtbl.get(cache, grid) {
        Ok(i) -> {
          let assert Ok(rem) = int.remainder(n, i - n)
          grid |> cycle |> run_cycles(cache, rem - 1)
        }
        Error(Nil) -> {
          hashtbl.insert(cache, grid, n)
          grid |> cycle |> run_cycles(cache, n - 1)
        }
      }
    }
  }
}

pub fn part1(input: String) -> Int {
  input
  |> parse
  |> tilt
  |> list.map(load)
  |> list.fold(0, fn(a, b) { a + b })
}

pub fn part2(input: String) -> Int {
  use cache <- hashtbl.new()
  input
  |> parse
  |> run_cycles(cache, 1_000_000_000)
  |> list.map(load)
  |> list.fold(0, fn(a, b) { a + b })
}
