import aoc/argp/arg.{type Arg}
import aoc/argp/flag.{type Flag}
import aoc/argp/internal/aliases.{type ArgsFn}
import aoc/argp/internal/arg_info.{type ArgInfo, ArgInfo, FlagInfo}
import aoc/argp/opt.{type Opt}
import gleam/option.{Some}
import gleam/result
import gleam/string

pub opaque type Command(a) {
  Command(info: ArgInfo, f: ArgsFn(a))
}

pub fn pure(val: a) -> Command(a) {
  Command(info: arg_info.empty(), f: fn(args) { Ok(#(val, args)) })
}

pub fn apply(mf: Command(fn(a) -> b), ma: Command(a)) -> Command(b) {
  Command(info: arg_info.merge(mf.info, ma.info), f: fn(args) {
    use #(f, args1) <- result.try(mf.f(args))
    use #(a, args2) <- result.try(ma.f(args1))
    Ok(#(f(a), args2))
  })
}

pub fn command(f: fn(a) -> b) -> Command(fn(a) -> b) {
  pure(f)
}

pub fn opt(command: Command(fn(a) -> b), opt: Opt(a)) -> Command(b) {
  apply(command, Command(info: opt.to_arg_info(opt), f: opt.run(opt, _)))
}

pub fn arg(command: Command(fn(a) -> b), arg: Arg(a)) -> Command(b) {
  apply(command, Command(info: arg.to_arg_info(arg), f: arg.run(arg, _)))
}

pub fn flag(command: Command(fn(Bool) -> b), flag: Flag) -> Command(b) {
  apply(command, Command(info: flag.to_arg_info(flag), f: flag.run(flag, _)))
}

pub fn rest(command: Command(fn(List(String)) -> b), name: String) -> Command(b) {
  apply(
    command,
    Command(info: ArgInfo(..arg_info.empty(), rest: Some(name)), f: fn(args) {
      Ok(#(args, []))
    }),
  )
}

pub fn info(command: Command(a)) -> ArgInfo {
  command.info
}

pub fn add_help(
  command: Command(a),
  name: String,
  description: String,
) -> Command(a) {
  let help_info =
    ArgInfo(
      ..arg_info.empty(),
      flags: [
        FlagInfo(name: "help", short: Some("h"), help: Some("Print this help")),
      ],
    )
  Command(
    ..command,
    f: fn(args) {
      case args {
        ["-h", ..] | ["--help", ..] ->
          Error(arg_info.help_text(
            arg_info.merge(help_info, command.info),
            name,
            description,
          ))
        other ->
          command.f(other)
          |> result.map_error(fn(e) {
            string.join([e, arg_info.usage_text(command.info, name)], "\n\n")
          })
      }
    },
  )
}

pub fn run(command: Command(a), args: List(String)) -> Result(a, String) {
  case command.f(args) {
    Ok(#(a, _)) -> Ok(a)
    Error(e) -> Error(e)
  }
}
