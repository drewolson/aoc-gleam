import aoc/util/str
import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string

type Coord =
  #(Int, Int)

type Grid =
  Dict(Coord, String)

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

pub fn expand(input: String) -> String {
  input
  |> str.lines
  |> list.flat_map(fn(l) {
    let new_l =
      l
      |> string.to_graphemes
      |> list.flat_map(fn(g) { [g, g] })
      |> string.join("")

    [new_l, new_l]
  })
  |> string.join("\n")
}

fn neighbors(coord: Coord) -> List(Coord) {
  let #(x, y) = coord
  [#(x + 1, y), #(x - 1, y), #(x, y + 1), #(x, y - 1)]
}

fn diagonals(coord: Coord) -> List(Coord) {
  let #(x, y) = coord
  [#(x + 1, y + 1), #(x - 1, y + 1), #(x + 1, y - 1), #(x - 1, y - 1)]
}

fn flood(grid: Grid, curr: Set(Coord), seen: Set(Coord)) -> Set(Coord) {
  case set.is_empty(curr) {
    True -> seen
    False -> {
      let seen = set.union(seen, curr)
      let next =
        set.fold(curr, set.new(), fn(acc, coord) {
          let v = dict.get(grid, coord) |> result.unwrap("")

          coord
          |> neighbors
          |> list.filter(fn(c) {
            dict.get(grid, c) == Ok(v) && !set.contains(seen, c)
          })
          |> set.from_list
          |> set.union(acc)
        })

      flood(grid, next, seen)
    }
  }
}

fn perimeter(set: Set(Coord)) -> Int {
  set.fold(set, 0, fn(sum, c) {
    sum
    + {
      c
      |> neighbors
      |> list.count(fn(n) { !set.contains(set, n) })
    }
  })
}

fn corners(set: Set(Coord)) -> Int {
  let counts =
    set.fold(set, dict.new(), fn(d, c) {
      c
      |> neighbors
      |> list.filter(fn(n) { !set.contains(set, n) })
      |> list.fold(d, fn(d, n) {
        dict.upsert(d, n, fn(o) {
          case o {
            None -> 1
            Some(c) -> c + 1
          }
        })
      })
    })

  set
  |> set.fold(set.new(), fn(s, c) {
    c
    |> diagonals
    |> list.filter(fn(d) {
      !set.contains(set, d) && { dict.get(counts, d) != Ok(1) }
    })
    |> set.from_list
    |> set.union(s)
  })
  |> set.size
}

fn find_groups(grid: Grid) -> List(Set(Coord)) {
  let #(_, sets) =
    grid
    |> dict.keys
    |> list.fold(#(set.new(), []), fn(acc, coord) {
      let #(seen, sets) = acc
      case set.contains(seen, coord) {
        True -> #(seen, sets)
        False -> {
          let set = flood(grid, set.from_list([coord]), set.new())
          #(set.union(seen, set), [set, ..sets])
        }
      }
    })

  sets
}

pub fn part1(input: String) -> Int {
  let grid = make_grid(input)
  let sets = find_groups(grid)

  list.fold(sets, 0, fn(sum, set) { sum + set.size(set) * perimeter(set) })
}

pub fn part2(input: String) -> Int {
  let grid = input |> expand |> make_grid
  let sets = find_groups(grid)

  list.fold(sets, 0, fn(sum, set) { sum + { set.size(set) / 4 } * corners(set) })
}
