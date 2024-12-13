import aoc/util/li
import aoc/util/parser.{type Parser}
import gleam/list
import party

type Coord =
  #(Int, Int)

type Config =
  #(Coord, Coord, Coord)

fn coord_p(sep: String) -> Parser(Coord) {
  party.return(fn(a) { fn(b) { #(a, b) } })
  |> parser.skip(party.string("X" <> sep))
  |> parser.keep(parser.int())
  |> parser.skip(party.string(", Y" <> sep))
  |> parser.keep(parser.int())
}

fn button_p() -> Parser(Coord) {
  coord_p("+")
}

fn prize_p() -> Parser(Coord) {
  coord_p("=")
}

fn config_p() -> Parser(Config) {
  party.return(fn(a) { fn(b) { fn(c) { #(a, b, c) } } })
  |> parser.skip(party.string("Button A: "))
  |> parser.keep(button_p())
  |> parser.skip(party.string("\nButton B: "))
  |> parser.keep(button_p())
  |> parser.skip(party.string("\nPrize: "))
  |> parser.keep(prize_p())
}

fn configs_p() -> Parser(List(Config)) {
  party.sep1(config_p(), party.string("\n\n"))
}

fn token_count(config: Config) -> Result(Int, Nil) {
  let #(#(ax, ay), #(bx, by), #(gx, gy)) = config

  let a = { bx * gy - gx * by } / { bx * ay - ax * by }
  let b = { gx - ax * a } / bx

  case a * ax + b * bx == gx && a * ay + b * by == gy {
    True -> Ok(a * 3 + b)
    False -> Error(Nil)
  }
}

pub fn part1(input: String) -> Int {
  input
  |> parser.go(configs_p())
  |> list.filter_map(token_count)
  |> li.sum
}

pub fn part2(input: String) -> Int {
  input
  |> parser.go(configs_p())
  |> list.map(fn(c) {
    #(c.0, c.1, #(c.2.0 + 10_000_000_000_000, c.2.1 + 10_000_000_000_000))
  })
  |> list.filter_map(token_count)
  |> li.sum
}
