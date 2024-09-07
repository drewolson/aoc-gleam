import aoc/argp
import aoc/argp/arg
import aoc/argp/flag
import aoc/argp/opt
import gleam/list
import gleeunit/should

pub fn complex_command_test() {
  let result =
    argp.command(fn(a) { fn(b) { fn(c) { fn(d) { #(a, b, c, d) } } } })
    |> argp.opt(opt.new("a"))
    |> argp.flag(flag.new("b"))
    |> argp.arg(arg.new("c"))
    |> argp.arg_many(arg.new("d"))
    |> argp.run(["--a", "a", "--b", "c", "d", "e", "f"])

  result
  |> should.equal(Ok(#("a", True, "c", ["d", "e", "f"])))
}

pub fn opt_and_flag_order_does_not_matter_test() {
  let argv =
    [["--a", "a"], ["--b"], ["c", "d", "e", "f"]] |> list.shuffle |> list.concat

  let result =
    argp.command(fn(a) { fn(b) { fn(c) { fn(d) { #(a, b, c, d) } } } })
    |> argp.opt(opt.new("a"))
    |> argp.flag(flag.new("b"))
    |> argp.arg(arg.new("c"))
    |> argp.arg_many(arg.new("d"))
    |> argp.run(argv)

  result
  |> should.equal(Ok(#("a", True, "c", ["d", "e", "f"])))
}
