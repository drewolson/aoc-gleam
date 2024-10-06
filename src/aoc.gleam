import aoc/runner
import argv
import clip
import clip/opt
import gleam/io
import gleam/result
import gleam/set
import gleam/string

fn valid_years() {
  set.from_list([2023, 2024])
}

fn day_opt() {
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

fn part_opt() {
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

fn year_opt() {
  opt.new("year")
  |> opt.short("y")
  |> opt.help("Year to run")
  |> opt.int
  |> opt.try_map(fn(year) {
    let years = valid_years()
    let years_str = years |> set.to_list |> string.inspect
    case set.contains(years, year) {
      True -> Ok(year)
      False -> Error("Year must be in " <> years_str)
    }
  })
  |> opt.default(2024)
}

fn command() {
  clip.command({
    use year <- clip.parameter
    use day <- clip.parameter
    use part <- clip.parameter

    runner.run(year, day, part)
  })
  |> clip.opt(year_opt())
  |> clip.opt(day_opt())
  |> clip.opt(part_opt())
}

pub fn main() {
  command()
  |> clip.add_help("aoc", "run aoc solution")
  |> clip.run(argv.load().arguments)
  |> result.flatten
  |> result.map(io.println)
  |> result.map_error(io.println_error)
}
