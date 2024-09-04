import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

pub type NamedInfo {
  NamedInfo(
    name: String,
    short: Option(String),
    default: Option(String),
    help: Option(String),
  )
}

pub type PositionalInfo {
  PositionalInfo(name: String, default: Option(String), help: Option(String))
}

pub type FlagInfo {
  FlagInfo(name: String, short: Option(String), help: Option(String))
}

pub type ArgInfo {
  ArgInfo(
    named: List(NamedInfo),
    positional: List(PositionalInfo),
    flags: List(FlagInfo),
    rest: Bool,
  )
}

fn named_str(n_info: NamedInfo) -> String {
  let long_name = "--" <> n_info.name
  let short_name = option.map(n_info.short, fn(s) { "-" <> s })
  let names = short_name |> option.map(fn(s) { [s] }) |> option.unwrap([])
  let names_list = [long_name, ..names]
  let #(start, end) = case n_info.default {
    Some(_) -> #("[", "]")
    None -> #("(", ")")
  }
  start
  <> { string.join(names_list, ",") }
  <> " "
  <> string.uppercase(n_info.name)
  <> end
}

fn flag_str(f_info: FlagInfo) -> String {
  let long_name = "--" <> f_info.name
  let short_name = option.map(f_info.short, fn(s) { "-" <> s })
  let names = short_name |> option.map(fn(s) { [s] }) |> option.unwrap([])
  let names_list = [long_name, ..names]
  "[" <> { string.join(names_list, ",") } <> "]"
}

pub fn empty() -> ArgInfo {
  ArgInfo(named: [], positional: [], flags: [], rest: False)
}

pub fn merge(a: ArgInfo, b: ArgInfo) -> ArgInfo {
  ArgInfo(
    named: list.append(a.named, b.named),
    positional: list.append(a.positional, b.positional),
    flags: list.append(a.flags, b.flags),
    rest: a.rest || b.rest,
  )
}

pub fn help_text(info: ArgInfo, name: String, description: String) -> String {
  let named_args =
    info.named
    |> list.map(named_str)

  let flag_args =
    info.flags
    |> list.map(flag_str)

  let max_size =
    named_args
    |> list.append(flag_args)
    |> list.map(string.length)
    |> list.fold(0, int.max)

  let positional_args =
    list.map(info.positional, fn(p_info) { string.uppercase(p_info.name) })

  let rest_args = case info.rest {
    True -> ["[..REST]"]
    False -> []
  }

  let usage =
    string.join(
      [name]
        |> list.append(named_args)
        |> list.append(flag_args)
        |> list.append(positional_args)
        |> list.append(rest_args),
      " ",
    )

  let named_desc =
    info.named
    |> list.map(fn(n_info) {
      let names =
        n_info
        |> named_str
        |> string.pad_right(max_size, " ")

      case n_info.default {
        None -> names <> "\t" <> n_info.help |> option.unwrap("")
        Some(v) ->
          names
          <> "\t"
          <> n_info.help
          |> option.map(fn(h) { h <> " (default: " <> v <> ")" })
          |> option.unwrap("")
      }
    })
    |> string.join("\n")

  let flag_desc =
    info.flags
    |> list.map(fn(f_info) {
      f_info
      |> flag_str
      |> string.pad_right(max_size, " ")
      <> "\t"
      <> f_info.help
      |> option.unwrap("")
    })
    |> string.join("\n")

  let opt_desc = string.join([named_desc, flag_desc], "\n")

  string.join(
    [
      name <> " -- " <> description,
      "Usage: " <> usage,
      "Available options:",
      opt_desc,
    ],
    "\n\n",
  )
}

pub fn usage_text(_info: ArgInfo, name: String) -> String {
  "For usage information, run\n  " <> name <> " --help"
}
