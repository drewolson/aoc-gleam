import aoc/util/parser.{type Parser}
import gleam/int
import gleam/list
import gleam/result
import party

type Color {
  Red
  Green
  Blue
}

type Draw {
  Draw(n: Int, color: Color)
}

type Round =
  List(Draw)

type Game {
  Game(id: Int, rounds: List(Round))
}

fn color_p() -> Parser(Color) {
  party.choice([
    party.string("red") |> parser.replace(Red),
    party.string("blue") |> parser.replace(Blue),
    party.string("green") |> parser.replace(Green),
  ])
}

fn draw_p() -> Parser(Draw) {
  use n <- party.do(parser.int() |> parser.skip(party.whitespace1()))
  use color <- party.do(color_p())

  party.return(Draw(n, color))
}

fn round_p() -> Parser(Round) {
  party.sep1(draw_p(), party.string(", "))
}

fn game_p() -> Parser(Game) {
  use n <- party.do(
    party.string("Game ")
    |> parser.keep(parser.int())
    |> parser.skip(party.string(": ")),
  )
  use rounds <- party.do(party.sep1(round_p(), party.string("; ")))

  party.return(Game(n, rounds))
}

fn games_p() -> Parser(List(Game)) {
  party.sep1(game_p(), party.string("\n"))
}

fn round_count(round: Round) -> #(Int, Int, Int) {
  list.fold(round, #(0, 0, 0), fn(acc, draw) {
    case draw {
      Draw(n, Red) -> #(int.max(n, acc.0), acc.1, acc.2)
      Draw(n, Green) -> #(acc.0, int.max(n, acc.1), acc.2)
      Draw(n, Blue) -> #(acc.0, acc.1, int.max(n, acc.2))
    }
  })
}

fn game_count(game: Game) -> #(Int, Int, Int) {
  list.fold(game.rounds, #(0, 0, 0), fn(acc, round) {
    let #(r, g, b) = round_count(round)

    #(int.max(r, acc.0), int.max(g, acc.1), int.max(b, acc.2))
  })
}

fn valid_round(round: Round) -> Bool {
  let #(r, g, b) = round_count(round)

  r <= 12 && g <= 13 && b <= 14
}

fn valid_game(game: Game) -> Bool {
  list.all(game.rounds, valid_round)
}

pub fn part1(input: String) -> Int {
  input
  |> party.go(games_p(), _)
  |> result.unwrap([])
  |> list.filter(valid_game)
  |> list.fold(0, fn(sum, g) { sum + g.id })
}

pub fn part2(input: String) -> Int {
  input
  |> party.go(games_p(), _)
  |> result.unwrap([])
  |> list.map(fn(game) {
    let #(r, g, b) = game_count(game)
    r * g * b
  })
  |> list.fold(0, fn(sum, power) { sum + power })
}
