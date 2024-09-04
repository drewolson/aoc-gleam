import aoc/argp/internal/aliases.{type Args, type FnResult}
import aoc/argp/internal/arg_info.{type ArgInfo, ArgInfo, NamedInfo}
import gleam/float
import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

pub opaque type Opt(a) {
  Opt(
    name: String,
    default: Option(a),
    help: Option(String),
    constraint: fn(String) -> Result(a, String),
    short: Option(String),
  )
}

pub fn to_arg_info(opt: Opt(a)) -> ArgInfo {
  case opt {
    Opt(name:, short:, default:, help:, constraint: _) ->
      ArgInfo(
        ..arg_info.empty(),
        named: [
          NamedInfo(
            name:,
            short:,
            default: default |> option.map(string.inspect),
            help:,
          ),
        ],
      )
  }
}

pub fn constrain(opt: Opt(a), f: fn(a) -> Result(b, String)) -> Opt(b) {
  case opt {
    Opt(name:, short:, default: _, help:, constraint:) ->
      Opt(name:, short:, default: None, help:, constraint: fn(arg) {
        use a <- result.try(constraint(arg))
        f(a)
      })
  }
}

pub fn with_default(opt: Opt(a), default: a) -> Opt(a) {
  case opt {
    Opt(name:, short:, default: _, help:, constraint:) ->
      Opt(name:, short:, default: Some(default), help:, constraint:)
  }
}

pub fn help(opt: Opt(a), help: String) -> Opt(a) {
  case opt {
    Opt(name:, short:, default:, help: _, constraint:) ->
      Opt(name:, short:, default:, help: Some(help), constraint:)
  }
}

pub fn named(name: String) -> Opt(String) {
  Opt(name:, short: None, default: None, help: None, constraint: Ok)
}

pub fn short(opt: Opt(String), short_name: String) -> Opt(String) {
  case opt {
    Opt(name:, short: _, default:, help:, constraint:) ->
      Opt(name:, short: Some(short_name), default:, help:, constraint:)
  }
}

pub fn int(opt: Opt(String)) -> Opt(Int) {
  opt
  |> constrain(fn(val) {
    int.parse(val)
    |> result.map_error(fn(_) { "Non-integer value provided for " <> opt.name })
  })
}

pub fn float(opt: Opt(String)) -> Opt(Float) {
  opt
  |> constrain(fn(val) {
    float.parse(val)
    |> result.map_error(fn(_) { "Non-float value provided for " <> opt.name })
  })
}

pub fn run(opt: Opt(a), args: Args) -> FnResult(a) {
  let long_name = "--" <> opt.name
  let short_name = option.map(opt.short, fn(s) { "-" <> s })
  let names = short_name |> option.map(fn(s) { [s] }) |> option.unwrap([])
  let names = [long_name, ..names] |> string.join(", ")
  case args, opt.default {
    [key, val, ..rest], _ if key == long_name || Some(key) == short_name -> {
      use a <- result.try(opt.constraint(val))
      Ok(#(a, rest))
    }
    [head, ..rest], _ ->
      run(opt, rest)
      |> result.map(fn(v) { #(v.0, [head, ..v.1]) })
    [], Some(v) -> Ok(#(v, []))
    [], None -> Error("missing required arg: " <> names)
  }
}
