import aoc/util/li
import aoc/util/parser.{type Parser}
import gleam/int
import gleam/list
import pears/chars
import pears/combinators

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
  combinators.choice([
    chars.string("red") |> combinators.replace(Red),
    chars.string("blue") |> combinators.replace(Blue),
    chars.string("green") |> combinators.replace(Green),
  ])
}

fn draw_p() -> Parser(Draw) {
  use n <- combinators.then(chars.natural())
  use <- parser.drop(chars.whitespace1())
  use color <- combinators.then(color_p())

  combinators.succeed(Draw(n, color))
}

fn round_p() -> Parser(Round) {
  combinators.sep_by1(draw_p(), chars.string(", "))
}

fn game_p() -> Parser(Game) {
  use <- parser.drop(chars.string("Game "))
  use n <- combinators.then(chars.natural())
  use <- parser.drop(chars.string(": "))
  use rounds <- combinators.then(combinators.sep_by1(
    round_p(),
    chars.string("; "),
  ))

  combinators.succeed(Game(n, rounds))
}

fn games_p() -> Parser(List(Game)) {
  combinators.sep_by1(game_p(), chars.string("\n"))
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
  |> parser.go(games_p())
  |> list.filter(valid_game)
  |> list.fold(0, fn(sum, g) { sum + g.id })
}

pub fn part2(input: String) -> Int {
  input
  |> parser.go(games_p())
  |> list.map(fn(game) {
    let #(r, g, b) = game_count(game)
    r * g * b
  })
  |> li.sum
}
