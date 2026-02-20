import aoc/util/li
import aoc/util/state.{type State} as s
import aoc/util/str
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/string

type Grid =
  List(List(String))

type Cache =
  Dict(Grid, Int)

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

fn shift_rocks(l: List(String)) -> List(String) {
  let #(rocks, l) =
    list.fold(l, #([], []), fn(acc, rock) {
      case rock, acc {
        "O", #(rocks, l) -> #(["O", ..rocks], l)
        ".", #(rocks, l) -> #(rocks, [".", ..l])
        "#", #(rocks, l) -> #([], list.append(["#", ..rocks], l))
        _, p -> p
      }
    })

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
  li.range(0, 3)
  |> list.fold(grid, fn(grid, _) { grid |> tilt |> rotate })
}

fn run_cycles(grid: Grid, n: Int) -> State(Cache, Grid) {
  case n {
    0 -> s.return(grid)
    n -> {
      use result <- s.do(s.gets(dict.get(_, grid)))

      case result {
        Ok(i) -> {
          let assert Ok(rem) = int.remainder(n, i - n)
          grid |> cycle |> run_cycles(rem - 1)
        }
        Error(Nil) -> {
          use _ <- s.do(s.modify(dict.insert(_, grid, n)))
          grid |> cycle |> run_cycles(n - 1)
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
  |> li.sum
}

pub fn part2(input: String) -> Int {
  input
  |> parse
  |> run_cycles(1_000_000_000)
  |> s.eval(dict.new())
  |> list.map(load)
  |> li.sum
}
