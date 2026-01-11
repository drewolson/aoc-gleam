import aoc/runner
import argv
import clip.{type Command}
import clip/help
import clip/opt.{type Opt}
import gleam/io
import gleam/set.{type Set}
import gleam/string

fn valid_years() -> Set(Int) {
  set.from_list([2019, 2023, 2024, 2025])
}

fn day_opt() -> Opt(Int) {
  opt.new("day")
  |> opt.short("d")
  |> opt.help("Day to run")
  |> opt.int
  |> opt.try_map(fn(day) {
    case day > 0 && day <= 25 {
      True -> Ok(day)
      False -> Error("Day must be between 1 and 25")
    }
  })
}

fn part_opt() -> Opt(Int) {
  opt.new("part")
  |> opt.short("p")
  |> opt.help("Part to run")
  |> opt.int
  |> opt.try_map(fn(part) {
    case part == 1 || part == 2 {
      True -> Ok(part)
      False -> Error("Part must be 1 or 2")
    }
  })
}

fn year_opt() -> Opt(Int) {
  opt.new("year")
  |> opt.short("y")
  |> opt.help("Year to run")
  |> opt.int
  |> opt.try_map(fn(year) {
    let years = valid_years()

    case set.contains(years, year) {
      True -> Ok(year)
      False -> {
        let years_str = years |> set.to_list |> string.inspect

        Error("Year must be in " <> years_str)
      }
    }
  })
  |> opt.default(2025)
}

fn command() -> Command(#(Int, Int, Int)) {
  clip.command({
    use year <- clip.parameter
    use day <- clip.parameter
    use part <- clip.parameter

    #(year, day, part)
  })
  |> clip.opt(year_opt())
  |> clip.opt(day_opt())
  |> clip.opt(part_opt())
}

@external(erlang, "erlang", "halt")
fn halt() -> Nil

pub fn main() -> Nil {
  let result =
    command()
    |> clip.help(help.simple("aoc", "run aoc solution"))
    |> clip.run(argv.load().arguments)

  case result {
    Error(str) -> io.println_error(str)
    Ok(#(year, day, part)) ->
      runner.run(year, day, part)
      |> io.println
  }

  halt()
}
