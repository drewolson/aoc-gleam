import aoc/argp/internal/aliases.{type Args, type FnResult}
import aoc/argp/internal/arg_info.{type ArgInfo, ArgInfo, PositionalInfo}
import gleam/float
import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

pub opaque type Arg(a) {
  Arg(
    name: String,
    default: Option(a),
    help: Option(String),
    constraint: fn(String) -> Result(a, String),
  )
}

pub fn to_arg_info(arg: Arg(a)) -> ArgInfo {
  case arg {
    Arg(name:, default:, help:, constraint: _) ->
      ArgInfo(
        ..arg_info.empty(),
        positional: [
          PositionalInfo(
            name:,
            default: default |> option.map(string.inspect),
            help:,
          ),
        ],
      )
  }
}

pub fn constrain(arg: Arg(a), f: fn(a) -> Result(b, String)) -> Arg(b) {
  case arg {
    Arg(name:, default: _, help:, constraint:) ->
      Arg(name:, default: None, help:, constraint: fn(arg) {
        use a <- result.try(constraint(arg))
        f(a)
      })
  }
}

pub fn with_default(arg: Arg(a), default: a) -> Arg(a) {
  case arg {
    Arg(name:, default: _, help:, constraint:) ->
      Arg(name:, default: Some(default), help:, constraint:)
  }
}

pub fn help(arg: Arg(a), help: String) -> Arg(a) {
  case arg {
    Arg(name:, default:, help: _, constraint:) ->
      Arg(name:, default:, help: Some(help), constraint:)
  }
}

pub fn int(arg: Arg(String)) -> Arg(Int) {
  arg
  |> constrain(fn(val) {
    int.parse(val)
    |> result.map_error(fn(_) { "Non-integer value provided for " <> arg.name })
  })
}

pub fn float(arg: Arg(String)) -> Arg(Float) {
  arg
  |> constrain(fn(val) {
    float.parse(val)
    |> result.map_error(fn(_) { "Non-float value provided for " <> arg.name })
  })
}

pub fn next(name: String) -> Arg(String) {
  Arg(name:, default: None, help: None, constraint: Ok)
}

pub fn run(arg: Arg(a), args: Args) -> FnResult(a) {
  let long_name = "--" <> arg.name
  case args, arg.default {
    [flag, val, ..rest], _ if flag == long_name -> {
      use a <- result.try(arg.constraint(val))
      Ok(#(a, rest))
    }
    [head, ..rest], _ ->
      run(arg, rest)
      |> result.map(fn(v) { #(v.0, [head, ..v.1]) })
    [], Some(v) -> Ok(#(v, []))
    [], None -> Error("missing required arg: " <> arg.name)
  }
}
