import aoc/argp
import aoc/argp/opt
import argv
import gleam/io

type Args {
  Args(year: Int, day: Int, part: Int)
}

fn day_opt() {
  opt.named("day")
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

fn part_opt() {
  opt.named("part")
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

fn year_opt() {
  opt.named("year")
  |> opt.short("y")
  |> opt.help("Year to run")
  |> opt.int
  |> opt.try_map(fn(year) {
    case year == 2023 {
      True -> Ok(year)
      False -> Error("Invalid year")
    }
  })
  |> opt.default(2023)
}

fn command() {
  argp.command(fn(year) { fn(day) { fn(part) { Args(year, day, part) } } })
  |> argp.opt(year_opt())
  |> argp.opt(day_opt())
  |> argp.opt(part_opt())
}

pub fn main() {
  let result =
    command()
    |> argp.add_help("aoc", "run aoc solution")
    |> argp.run(argv.load().arguments)

  case result {
    Error(e) -> io.println_error(e)
    Ok(args) -> {
      io.debug(args)
      Nil
    }
  }
}
