import aoc/util/li
import aoc/util/parser.{type Parser}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleam/yielder.{type Yielder, Next}
import party

type Pair =
  #(Int, Int)

type Robot =
  #(Pair, Pair)

fn pair_p() -> Parser(#(Int, Int)) {
  use a <- party.do(parser.signed_int())
  use <- party.drop(party.string(","))
  use b <- party.map(parser.signed_int())
  #(a, b)
}

fn robot_p() -> Parser(Robot) {
  party.return(fn(p) { fn(v) { #(p, v) } })
  |> parser.skip(party.string("p="))
  |> parser.keep(pair_p())
  |> parser.skip(party.string(" v="))
  |> parser.keep(pair_p())
}

fn robots_p() -> Parser(List(Robot)) {
  party.sep1(robot_p(), party.string("\n"))
}

fn mod(a: Int, b: Int) -> Int {
  a |> int.modulo(b) |> result.unwrap(0)
}

fn move(r: Robot, w: Int, h: Int) -> Robot {
  let #(#(x, y), #(vx, vy)) = r

  #(#(mod(x + vx, w), mod(y + vy, h)), #(vx, vy))
}

fn states(robots: List(Robot), w: Int, h: Int) -> Yielder(List(Robot)) {
  yielder.unfold(robots, fn(rs) {
    let next = list.map(rs, fn(r) { move(r, w, h) })

    Next(rs, next)
  })
}

fn safety(robots: List(Robot), w: Int, h: Int) -> Int {
  let hw = w / 2
  let hh = h / 2
  let qs = [
    #(#(0, hw - 1), #(0, hh - 1)),
    #(#(hw + 1, w - 1), #(hh + 1, h - 1)),
    #(#(0, hw - 1), #(hh + 1, h - 1)),
    #(#(hw + 1, w - 1), #(0, hh - 1)),
  ]
  qs
  |> list.map(fn(q) {
    let #(#(minx, maxx), #(miny, maxy)) = q
    list.count(robots, fn(r) {
      let #(#(x, y), _) = r
      minx <= x && x <= maxx && miny <= y && y <= maxy
    })
  })
  |> list.fold(1, fn(p, c) { p * c })
}

fn neighbors(coord: Pair) -> List(Pair) {
  let #(x, y) = coord
  [
    #(x + 1, y),
    #(x - 1, y),
    #(x, y + 1),
    #(x, y - 1),
    #(x + 1, y + 1),
    #(x - 1, y + 1),
    #(x + 1, y - 1),
    #(x - 1, y - 1),
  ]
}

fn flood(unseen: Set(Pair), curr: Set(Pair), seen: Set(Pair)) -> Set(Pair) {
  case set.is_empty(curr) {
    True -> seen
    False -> {
      let seen = set.union(seen, curr)
      let next =
        set.fold(curr, set.new(), fn(acc, coord) {
          coord
          |> neighbors
          |> list.filter(fn(c) {
            set.contains(unseen, c) && !set.contains(seen, c)
          })
          |> set.from_list
          |> set.union(acc)
        })

      flood(unseen, next, seen)
    }
  }
}

fn find_groups(robots: List(Robot)) -> List(Set(Pair)) {
  let coords = robots |> list.map(fn(p) { p.0 }) |> set.from_list
  let #(_, sets) =
    set.fold(coords, #(set.new(), []), fn(acc, coord) {
      let #(seen, sets) = acc
      case set.contains(seen, coord) {
        True -> #(seen, sets)
        False -> {
          let unseen = set.difference(coords, seen)
          let set = flood(unseen, set.from_list([coord]), set.new())
          #(set.union(seen, set), [set, ..sets])
        }
      }
    })

  sets
}

fn display(l: List(Robot), w: Int, h: Int) -> Nil {
  let s = l |> list.map(fn(r) { r.0 }) |> set.from_list
  list.each(li.range(0, h - 1), fn(y) {
    li.range(0, w - 1)
    |> list.map(fn(x) {
      case set.contains(s, #(x, y)) {
        False -> "."
        True -> "#"
      }
    })
    |> string.join("")
    |> io.println
  })
}

fn is_easter_egg(p: #(List(Robot), Int)) -> Bool {
  let group_count = p.0 |> find_groups |> list.length
  group_count < 200
}

pub fn part1(input: String, w: Int, h: Int) -> Int {
  input
  |> parser.go(robots_p())
  |> states(w, h)
  |> yielder.at(100)
  |> result.unwrap([])
  |> safety(w, h)
}

pub fn part2(input: String, w: Int, h: Int) -> Int {
  input
  |> parser.go(robots_p())
  |> states(w, h)
  |> yielder.index
  |> yielder.find(is_easter_egg)
  |> result.map(fn(p) {
    display(p.0, w, h)
    p.1
  })
  |> result.unwrap(-1)
}
